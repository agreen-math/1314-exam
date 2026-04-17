import re

# ==========================================
# 1. HELPER FUNCTIONS
# ==========================================

def escape_currency(text):
    """Safely escapes dollar signs used for money so they do not trigger math mode."""
    return re.sub(r'(?<!\\)\$(\d)', r'\\$\1', text)

def strip_stxKnowl(text):
    """Force-strips \stxKnowl{...} wrappers from a block of text."""
    text = text.strip()
    match = re.search(r'\\stxKnowl\s*\{', text)
    if match:
        inner, _ = get_braced_content(text, match.end() - 1)
        return inner.strip()
    return text

def get_braced_content(text, start_index):
    """Extracts content within nested LaTeX braces."""
    if start_index >= len(text) or text[start_index] != "{":
        return None, start_index
    
    count = 1
    for i in range(start_index + 1, len(text)):
        if text[i] == "{":
            count += 1
        elif text[i] == "}":
            count -= 1
            
        if count == 0:
            return text[start_index + 1:i], i + 1
            
    return None, len(text)

# ==========================================
# 2. CUSTOM QUESTION PROCESSORS
# ==========================================

def process_q1_table(content):
    """Q1: Replaces the standard array with the Department's custom array styling."""
    content = content.replace(r"\[", r"{\centering {\renewcommand{\arraystretch}{3}" + "\n")
    content = content.replace(r"\]", r"}}")
    content = content.replace(r"\begin{array}", r"\begin{tabular}")
    content = content.replace(r"\end{array}", r"\end{tabular}")
    content = re.sub(r"\\rule\[.*?\]\{.*?\}\{.*?\}", "", content) 
    content = content.replace(r"\hspace{3cm}", r"\hspace{75mm}")
    return content

def process_transformations(content):
    """Q7/Q8: Extracts the function and injects the Department's transformation table & grid."""
    func_match = re.search(r"\\\(f\(x\)\s*=\s*(.*?)\\\)", content)
    func = func_match.group(1) if func_match else "f(x)"
    
    dept_str = r"""Use the table to identify the transformations described by $f(x)=""" + func + r"""$. Circle the option that applies and fill in the blanks as appropriate to describe the transformations on the given function. If one does not apply, you may leave it blank. Then sketch the graph of the transformed function on the grid below. Indicate any asymptotes with dashed lines.\\
\begin{table}[h]
    \renewcommand{\arraystretch}{3} 
    \centering
    \begin{tabular}{|l|l|}
        \hline
        \textbf{Horizontal Transformations}               & \textbf{Vertical Transformations}              \\ \hline
        Reflection: YES    or     NO       & Reflection:       YES    or     NO    \\ \hline
        Dilation: \underline{\hspace{2cm}} times as wide           & Dilation: \underline{\hspace{2cm}} times as tall        \\ \hline
        Translation: \underline{\hspace{2cm}} units LEFT or RIGHT & Translation: \underline{\hspace{2cm}} units UP or DOWN \\ \hline
    \end{tabular}
\end{table}

\begin{center}
\scalebox{0.75}{
    \begin{tikzpicture}[>=triangle 45]
      \draw [step=.5cm, style={black!60}] (-5.4,-5.4) grid (5.4,5.4);
      \draw [->, line width=2] (-5.5,0) -- (5.5,0); 
      \draw [->, line width=2] (0,-5.5) -- (0,5.5);
    \end{tikzpicture}	 }
\end{center}"""
    return dept_str

def process_asymptotes(content):
    """Q13: Extracts the function and injects the Department's asymptote table."""
    func_match = re.search(r"\\\[f\(x\)\s*=\s*(.*?)\\\]", content)
    func = func_match.group(1) if func_match else "f(x)"
    
    dept_str = r"""List all of the vertical, horizontal, and oblique asymptotes of $f(x)=""" + func + r"""$.\\
\begin{center}
\renewcommand{\arraystretch}{3}
    \begin{tabular}{|c|c|}
        \hline
        \textbf{Asymptotes}  & \textbf{Equation} \\ \hline
        Vertical   & \hspace{50mm}         \\ \hline
        Horizontal &          \\ \hline
        Oblique    &          \\ \hline
    \end{tabular}
\end{center}"""
    return dept_str

def process_zeros(content):
    """Q14: Extracts the function and injects the Department's Zeros table."""
    func_match = re.search(r"\\\(f\(x\)\s*=\s*(.*?)\\\)", content)
    func = func_match.group(1) if func_match else "f(x)"
    
    dept_str = r"""Fill in the table below with the zeros of $f(x)=""" + func + r"""$, their multiplicities and the behavior of the graph of the function around each zero. You may or may not use all of the rows in the table.\\
\begin{center}
\renewcommand{\arraystretch}{3}
\begin{tabular}{|p{20mm}|p{25mm}|p{20mm}|}\hline
\textbf{Zero} & \textbf{Multiplicity} & \textbf{Behavior}\\ \hline
 & & \\ \hline
 & & \\ \hline
 & & \\ \hline
 & & \\ \hline
 & & \\ \hline
\end{tabular}
\end{center}"""
    return dept_str

def process_rational_graph(content):
    """Q15: Replaces the CheckIt graphing grid with the Department's scaled grid."""
    table_match = re.search(r"\\\[\\renewcommand\{\\arraystretch\}\{1\.4\}.*?\\end\{array\}\\\]", content, re.DOTALL)
    if not table_match:
        table_match = re.search(r"\\\[.*?\\end\{array\}\\\]", content, re.DOTALL)
    table_str = table_match.group(0) if table_match else ""
    
    dept_grid = r"""
\vspace{12pt}

\scalebox{1}{
    \begin{tikzpicture}[>=triangle 45]
      \draw [step=.5cm, style={black!60}] (-5.4,-5.4) grid (5.4,5.4);
      \draw [->, line width=2] (-5.5,0) -- (5.5,0); 
      \draw [->, line width=2] (0,-5.5) -- (0,5.5);
    \end{tikzpicture}	 }"""
    
    return r"Suppose a rational function has the attributes in the table below. Using only the holes, asymptotes, and intercepts listed along with as many of the helpful points as required, sketch the graph of the function.\\" + "\n" + table_str + "\n" + dept_grid

def process_poly_graph(content):
    """Q16: Extracts the generated TikZ image and builds the checkboxes manually."""
    graph_match = re.search(r"\\\[\\begin\{tikzpicture\}.*?\\end\{tikzpicture\}\\\]", content, re.DOTALL)
    graph_str = graph_match.group(0) if graph_match else ""
    
    parts_str = r"""
\begin{parts}
    \part[1] Is the degree of the polynomial even or odd? \\\\\begin{oneparcheckboxes}
    \choice even
    \choice odd
    \end{oneparcheckboxes}\\\vspace{.125in}
    \part[1\half] Is the lead coefficient of the polynomial positive or negative?\\\\ \begin{oneparcheckboxes}
    \choice positive
    \choice negative
    \end{oneparcheckboxes}\\\vspace{.125in}
    \part[1] Is the constant of the polynomial positive or negative? \\\\\begin{oneparcheckboxes}
    \choice positive
    \choice negative
    \end{oneparcheckboxes}\\\vspace{.125in}
    \part[1\half] What is the minimum degree? \\\\\fillin
\end{parts}"""
    
    return r"Use the image of a polynomial below to answer the questions that follow.\\" + "\n" + graph_str + "\n" + parts_str

# ==========================================
# 3. PARSER
# ==========================================

def parse_checkit_item(raw_block):
    """
    Parses a CheckIt block, rigorously separating the question text from the solution 
    so that LaTeX spatial formatting can be precisely injected between them.
    """
    match = re.search(r'\\stxKnowl\s*\{', raw_block)
    if not match: return None
    
    outer_content, _ = get_braced_content(raw_block, match.end() - 1)
    if not outer_content: return None

    solution_text = ""
    outtro_match = re.search(r'\\stxOuttro\s*\{', outer_content)
    
    if outtro_match:
        outtro_inner, _ = get_braced_content(outer_content, outtro_match.end() - 1)
        if outtro_inner is not None:
            solution_text = re.sub(r'^\s*SOLUTION\s*', '', outtro_inner, flags=re.IGNORECASE | re.MULTILINE).strip()
        outer_content = outer_content[:outtro_match.start()].strip()
        
    outer_content = re.sub(r'\\stxTitle\{.*?\}', '', outer_content).strip()

    if r'\begin{enumerate}' in outer_content or r'\begin{itemize}' in outer_content:
        # Handle both enumerate and itemize for multi-part questions
        list_type = r'\begin{enumerate}' if r'\begin{enumerate}' in outer_content else r'\begin{itemize}'
        end_list_type = list_type.replace('begin', 'end')
        
        # FIX: Use standard string split instead of regex split to avoid \b (word boundary) bugs!
        split_parts = outer_content.split(list_type, 1)
        intro_text = split_parts[0].strip()
        enum_body = split_parts[1].split(end_list_type)[0]
        
        # We can still safely use regex split here since \item doesn't trigger special escape chars
        raw_parts = re.split(r'\\item', enum_body)
        
        clean_parts = []
        for p in raw_parts:
            if not p.strip(): continue
            
            part_sol = ""
            part_match = re.search(r'\\stxKnowl\s*\{', p)
            
            if part_match:
                part_inner, _ = get_braced_content(p, part_match.end() - 1)
                
                if part_inner is not None:
                    p_outtro_match = re.search(r'\\stxOuttro\s*\{', part_inner)
                    if p_outtro_match:
                        p_outtro_inner, _ = get_braced_content(part_inner, p_outtro_match.end() - 1)
                        if p_outtro_inner is not None:
                            part_sol = re.sub(r'^\s*SOLUTION\s*', '', p_outtro_inner, flags=re.IGNORECASE | re.MULTILINE).strip()
                        part_inner = part_inner[:p_outtro_match.start()].strip()
                    clean_parts.append({"text": part_inner, "solution": part_sol})
                else:
                    clean_parts.append({"text": p.strip(), "solution": ""})
            else:
                clean_parts.append({"text": p.strip(), "solution": ""})
            
        return { 
            'type': 'parts', 
            'intro': intro_text, 
            'parts': clean_parts,
            'solution': solution_text
        }
    else:
        return { 
            'type': 'single', 
            'content': outer_content,
            'solution': solution_text
        }

# ==========================================
# 4. EXAM CONFIGURATION (16 Questions)
# ==========================================
    
EXAM_MAP = [
    # Q1: Exp/Log Table
    {
        "type": "single",
        "points": 5,
        "replacements": [
            (r"(Fill in the table to give an equivalent equation in the specified form\.)", r"\1\\\\")
        ],
        "custom_processor": process_q1_table
    },
    # Q2: Log Properties (Expand/Condense)
    {
        "type": "parts",
        "part_points": [5, 5],
        "replacements": [(r"(Use properties of logarithms to expand or condense the logarithmic expression as specified\.)", r"\1\\\\")],
        "part_replacements": [
            (r"(Rewrite as the sum or difference of logarithms\.\s*Express all powers as factors\.)\s*\\\[", r"\1\\\\ \\vspace{12pt}\n\\["),
            (r"(Rewrite as a single logarithm\.\s*Express all factors as powers\.)\s*\\\[", r"\1\\\\ \\\\\n\\[")
        ],
        "part_post_solution_space": [r"\vspace{\stretch{1}}\answerline", r"\vspace{\stretch{1}}\answerline"],
        "post_text": r"\newpage"
    },
    # Q3: Exponential Equation
    {
        "type": "single",
        "points": 6,
        "pre_text": r"\uplevel{For questions \ref{exact-start} through~\ref{exact-end}, solve for \textbf{all} solutions. Identify any extraneous solutions.}",
        "label": r"\label{exact-start} ",
        "replacements": [(r"(?i)Solve for \\?\(x\\?\) and identify any extraneous solutions\.\s*", "")],
        "post_solution_space": r"\vspace{\stretch{1}}" + "\n" + r"\uplevel{solutions: \fillin\fillin \hspace{\stretch{1}} extraneous solutions: \fillin\fillin}"
    },
    # Q4: Logarithmic Equation
    {
        "type": "single",
        "points": 6,
        "replacements": [(r"(?i)Solve for \\?\(x\\?\) and identify any extraneous solutions\.\s*", "")],
        "post_solution_space": r"\vspace{\stretch{1}}" + "\n" + r"\uplevel{solutions: \fillin\fillin \hspace{\stretch{1}} extraneous solutions: \fillin\fillin}"
    },
    # Q5: Logarithmic Equation (Part 2)
    {
        "type": "single",
        "points": 6,
        "label": r"\label{exact-end} ",
        "replacements": [(r"(?i)Solve for \\?\(x\\?\) and identify any extraneous solutions\.\s*", "")],
        "post_solution_space": r"\vspace{\stretch{1}}" + "\n" + r"\uplevel{solutions: \fillin\fillin \hspace{\stretch{1}} extraneous solutions: \fillin\fillin}",
        "post_text": r"\newpage"
    },
    # Q6: Savings Account
    {
        "type": "single",
        "points": 6,
        "post_solution_space": r"\vspace{\stretch{1}}\answerline",
        "post_text": r"\newpage"
    },
    # Q7: Transformations (Log)
    {
        "type": "single",
        "points": 5,
        "custom_processor": process_transformations,
        "post_text": r"\newpage"
    },
    # Q8: Transformations (Exp)
    {
        "type": "single",
        "points": 5,
        "custom_processor": process_transformations,
        "post_text": r"\newpage"
    },
    # Q9: System Word Problem
    {
        "type": "single",
        "points": 6,
        "pre_solution_space": r"\vspace{\stretch{1}}\\" + "\n" + r"student ticket:\fillin\hspace{\stretch{1}}general admission ticket:\fillin",
        "post_text": r"\newpage"
    },
    # Q10: Augmented Matrix
    {
        "type": "single",
        "points": 4,
        "post_solution_space": r"\vspace{\stretch{1}}" + "\n" + r"\renewcommand{\arraystretch}{1}"
    },
    # Q11: Row Operations
    {
        "type": "single",
        "points": 6,
        "pre_solution_space": r"\vspace{\stretch{5}}" + "\n" + r"\answerline",
        "post_text": r"\newpage"
    },
    # Q12: Domain & Range
    {
        "type": "parts",
        "part_points": [5, 5],
        "part_pre_solution_space": [
            r"\vspace{\stretch{1}}\\" + "\n" + r"domain:\fillin[\boxed{solution}][2in]\hspace{\stretch{1}}range:\fillin[\boxed{solution}][2in]",
            r"\vspace{\stretch{1}}\\" + "\n" + r"domain:\fillin[\boxed{solution}][2in]\hspace{\stretch{1}}range:\fillin[\boxed{solution}][2in]"
        ],
        "post_text": r"\newpage" + "\n" + r"\newpage"
    },
    # Q13: Asymptotes Table
    {
        "type": "single",
        "points": 5,
        "custom_processor": process_asymptotes,
        "post_solution_space": r"\vspace{\stretch{1}}"
    },
    # Q14: Zeros Table
    {
        "type": "single",
        "points": 10,
        "custom_processor": process_zeros,
        "post_text": r"\newpage"
    },
    # Q15: Rational Graph
    {
        "type": "single",
        "points": 5,
        "custom_processor": process_rational_graph,
        "post_text": r"\newpage"
    },
    # Q16: Polynomial Graph (Custom Manual Parts)
    {
        "type": "single",
        "points": None, 
        "custom_processor": process_poly_graph
    }
]

# ==========================================
# 5. GENERATOR
# ==========================================

PREAMBLE = r"""\documentclass[addpoints]{exam}

\usepackage[utf8]{inputenc}
\usepackage{array}
\usepackage{graphicx}
\usepackage{multicol}
\usepackage{amsmath}
\usepackage{tikz}
\usetikzlibrary{arrows}

\renewcommand*\half{.5}

\setlength\answerlinelength{3in}

%%%%% Question Info %%%%% 

%\printsolutions

%%%%% Header and Footer %%%%% 

\pagestyle{headandfoot}
\runningheadrule
\firstpageheader{Math 1314}{Non-Comprehensive Final Exam}{Fall 2025}
\runningheader{Math 1314}
{Non-Comprehensive Final Exam}
{Fall 2025}
\runningheadrule
\firstpagefooter{}{}{}
\runningfooter{}{Page \thepage\ of \numpages}{}

%%%%% Questions %%%%% 

\begin{document}

\uplevel{Number of Questions: \numquestions\hspace{\stretch{1}} Point Total: \numpoints}
\begin{questions}
"""

POSTAMBLE = r"""
\end{questions}
\end{document}
"""

def generate_latex_source(parsed_data, config):
    latex_lines = []
    
    if config.get("pre_text"):
        latex_lines.append(config["pre_text"])
        
    label_str = config.get("label", "")
    
    if parsed_data["type"] == "parts":
        header_prefix = config.get("header_prefix", r"\question ")
        intro_text = escape_currency(parsed_data['intro'])
        
        if 'replacements' in config:
            for (pat, repl) in config['replacements']:
                intro_text = re.sub(pat, repl, intro_text, flags=re.DOTALL)
                
        latex_lines.append(fr"{header_prefix} {label_str} {intro_text}")
        latex_lines.append(r"\begin{parts}")
        
        pts_cfg = config.get("part_points", [])
        pre_space_cfg = config.get("part_pre_solution_space", [])
        post_space_cfg = config.get("part_post_solution_space", [])
        
        for idx, part_dict in enumerate(parsed_data["parts"]):
            p_pts = pts_cfg[idx] if idx < len(pts_cfg) else 5
            pre_space = pre_space_cfg[idx] if idx < len(pre_space_cfg) else ""
            post_space = post_space_cfg[idx] if idx < len(post_space_cfg) else ""
            
            p_text = escape_currency(part_dict["text"])
            if 'part_replacements' in config:
                for (pat, repl) in config['part_replacements']:
                    p_text = re.sub(pat, repl, p_text, flags=re.DOTALL)
            
            clean_part = re.sub(r'^(\(\w\)|[\w]\)|[\w]\.)\s*', '', p_text)
            
            latex_lines.append(fr"    \part[{p_pts}] {clean_part}")
            
            if pre_space:
                latex_lines.append(f"    {pre_space}")
                
            if part_dict["solution"]:
                latex_lines.append(r"\begin{solution}")
                latex_lines.append(part_dict["solution"])
                latex_lines.append(r"\end{solution}")
                
            if post_space:
                latex_lines.append(f"    {post_space}")
                
        latex_lines.append(r"\end{parts}")
        
        if parsed_data["solution"]:
            latex_lines.append(r"\begin{solution}")
            latex_lines.append(parsed_data["solution"])
            latex_lines.append(r"\end{solution}")
            
    else:
        pts = config.get("points")
        pts_str = f"[{pts}]" if pts is not None else ""
        content = escape_currency(parsed_data["content"])
        
        if 'custom_processor' in config:
            content = config['custom_processor'](content)
            
        if 'replacements' in config:
            for (pat, repl) in config['replacements']:
                content = re.sub(pat, repl, content, flags=re.DOTALL)
                
        latex_lines.append(fr"\question{pts_str} {label_str} {content}")
        
        if config.get("pre_solution_space"):
            latex_lines.append(config["pre_solution_space"])
            
        if parsed_data["solution"]:
            latex_lines.append(r"\begin{solution}")
            latex_lines.append(parsed_data["solution"])
            latex_lines.append(r"\end{solution}")
            
    if config.get("post_solution_space"):
        latex_lines.append(config["post_solution_space"])
        
    if config.get("post_text"):
        latex_lines.append(config["post_text"])
        
    return "\n".join(latex_lines)

def process_checkit_bank(input_filename, output_filename):
    with open(input_filename, "r", encoding="utf-8") as f:
        raw_text = f.read()

    raw_blocks = re.split(r'\\item\s*%%%%% SpaTeXt Commands %%%%%', raw_text)
    
    if len(raw_blocks) > 0:
        raw_blocks = raw_blocks[1:]
        
    parsed_items = []
    for block in raw_blocks:
        if '\\stxKnowl' in block:
            item = parse_checkit_item(block)
            if item: 
                parsed_items.append(item)
                
    output_lines = []
    
    for idx, parsed in enumerate(parsed_items):
        if idx < len(EXAM_MAP):
            config = EXAM_MAP[idx]
        else:
            config = { "points": 5, "post_solution_space": r"\vspace{\stretch{1}}\answerline" }
            
        question_latex = generate_latex_source(parsed, config)
        output_lines.append(question_latex)
        output_lines.append("\n")
                
    with open(output_filename, "w", encoding="utf-8") as outfile:
        outfile.write(PREAMBLE)
        outfile.write("\n".join(output_lines))
        outfile.write(POSTAMBLE)

    print(f"Success! Processed {len(parsed_items)} questions and saved to {output_filename}")

if __name__ == "__main__":
    process_checkit_bank("CheckIt.tex", "Dept.tex")