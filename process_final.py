import re
import sys

# ==========================================
# 1. HELPER FUNCTIONS
# ==========================================

def escape_currency(text):
    """Safely escapes dollar signs used for money (e.g. $410 -> \$410) so they don't trigger math mode."""
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

def clean_solutions(content):
    """
    Finds CheckIt's \stxOuttro{SOLUTION ...} blocks and converts them 
    to exam class \begin{solution} ... \end{solution}.
    """
    content = re.sub(r'\\stxTitle\{.*?\}', '', content)
    while True:
        match = re.search(r'\\stxOuttro\s*\{', content)
        if not match: break
        start_pos = match.start()
        open_brace_pos = match.end() - 1
        inner_text, end_pos = get_braced_content(content, open_brace_pos)
        
        if inner_text is not None:
            inner_text = re.sub(r'^\s*SOLUTION\s*', '', inner_text, flags=re.IGNORECASE | re.MULTILINE).strip()
            new_block = r'\begin{solution}' + "\n" + inner_text + "\n" + r'\end{solution}'
            content = content[:start_pos] + new_block + content[end_pos:]
        else:
            break
    return content.strip()

# ==========================================
# 2. CUSTOM QUESTION PROCESSORS
# ==========================================

def process_q1_table(content):
    """Q1: Replaces the standard array with the Department's custom array styling, preserving math mode."""
    # Inject arraystretch into BOTH the question and solution arrays
    content = content.replace(r"\begin{array}", r"{\renewcommand{\arraystretch}{3}" + "\n" + r"\begin{array}")
    content = content.replace(r"\end{array}", r"\end{array}}")
    content = re.sub(r"\\rule\[.*?\]\{.*?\}\{.*?\}", "", content) # Strip CheckIt's vertical formatting rules
    content = content.replace(r"\hspace{3cm}", r"\hspace{75mm}")
    return content

def process_transformations(content):
    """Q7/Q8: Extracts the function and injects the Department's transformation table & grid."""
    func_match = re.search(r"\\\(f\(x\)\s*=\s*(.*?)\\\)", content)
    func = func_match.group(1) if func_match else "f(x)"
    
    dept_str = r"""Use the table to identify the transformations described by $f(x)=""" + func + r"""$. Circle the option that applies and fill in the blanks as appropriate to describe the transformations on the given function. If one does not apply, you may leave it blank. Then sketch the graph of the transformed function on the grid below. Indicate any asymptotes with dashed lines.\\
\begin{table}[h]
    \renewcommand{\arraystretch}{3} % Triple spacing
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
    table_str = table_match.group(0) if table_match else ""
    
    dept_grid = r"""
\vspace{12pt}

\scalebox{1}{
    \begin{tikzpicture}[>=triangle 45]
      \draw [step=.5cm, style={black!60}] (-5.4,-5.4) grid (5.4,5.4);
      \draw [->, line width=2] (-5.5,0) -- (5.5,0); 
      \draw [->, line width=2] (0,-5.5) -- (0,5.5);
    \end{tikzpicture}	 }"""
    
    return "Suppose a rational function has the attributes in the table below. Using only the holes, asymptotes, and intercepts listed along with as many of the helpful points as required, sketch the graph of the function.\\\\\n" + table_str + "\n" + dept_grid

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
    
    return "Use the image of a polynomial below to answer the questions that follow.\\\\\n" + graph_str + "\n" + parts_str

# ==========================================
# 3. PARSER
# ==========================================

def parse_checkit_item(raw_block):
    match = re.search(r'\\stxKnowl\s*\{', raw_block)
    if not match: return None
    outer_content, _ = get_braced_content(raw_block, match.end() - 1)
    
    if not outer_content: return None

    if r'\begin{enumerate}' in outer_content:
        split_parts = re.split(r'\\begin\{enumerate\}', outer_content, 1)
        intro_text = split_parts[0].strip()
        enum_body = split_parts[1].split(r'\end{enumerate}')[0]
        raw_parts = re.split(r'\\item', enum_body)
        
        clean_parts = []
        for p in raw_parts:
            if not p.strip(): continue
            clean_p = strip_stxKnowl(p)
            clean_parts.append(clean_solutions(clean_p))
            
        return { 
            'type': 'parts', 
            'intro': clean_solutions(intro_text), 
            'parts': clean_parts 
        }
    else:
        return { 
            'type': 'single', 
            'content': clean_solutions(outer_content) 
        }

# ==========================================
# 4. EXAM CONFIGURATION (16 Questions)
# ==========================================
    
EXAM_MAP = [
    # Q1: Exp/Log Table
    {
        "type": "single",
        "points": 5,
        "custom_processor": process_q1_table
    },
    # Q2: Log Properties (Expand/Condense)
    {
        "type": "parts",
        "points": [5, 5],
        "header_prefix": r"\question ",
        "part_spacing": r" \vspace{\stretch{1}}\answerline"
    },
    # Q3: Exponential Equation
    {
        "type": "single",
        "points": 6,
        "pre_text": r"\uplevel{For questions \ref{exact-start} through~\ref{exact-end}, solve for \textbf{all} solutions. Identify any extraneous solutions.}",
        "label": r"\label{exact-start}",
        "replacements": [(r"(?i)Solve for \\?\(x\\?\) and identify any extraneous solutions\.\s*", "")],
        "custom_space": r"\vspace{\stretch{1}}",
        "post_text": r"\par solutions: \fillin\fillin \hspace{\stretch{1}} extraneous solutions: \fillin\fillin"
    },
    # Q4: Logarithmic Equation
    {
        "type": "single",
        "points": 6,
        "replacements": [(r"(?i)Solve for \\?\(x\\?\) and identify any extraneous solutions\.\s*", "")],
        "custom_space": r"\vspace{\stretch{1}}",
        "post_text": r"\par solutions: \fillin\fillin \hspace{\stretch{1}} extraneous solutions: \fillin\fillin"
    },
    # Q5: Logarithmic Equation (Part 2)
    {
        "type": "single",
        "points": 6,
        "label": r"\label{exact-end}",
        "replacements": [(r"(?i)Solve for \\?\(x\\?\) and identify any extraneous solutions\.\s*", "")],
        "custom_space": r"\vspace{\stretch{1}}",
        "post_text": r"\par solutions: \fillin\fillin \hspace{\stretch{1}} extraneous solutions: \fillin\fillin \newpage"
    },
    # Q6: Savings Account
    {
        "type": "single",
        "points": 6,
        "custom_space": r"\vspace{\stretch{1}}\answerline \newpage"
    },
    # Q7: Transformations (Log)
    {
        "type": "single",
        "points": 5,
        "custom_processor": process_transformations,
        "custom_space": r"\newpage"
    },
    # Q8: Transformations (Exp)
    {
        "type": "single",
        "points": 5,
        "custom_processor": process_transformations,
        "custom_space": r"\newpage"
    },
    # Q9: System Word Problem
    {
        "type": "single",
        "points": 6,
        "replacements": [(r"([a-zA-Z\s]+):\s*_{5,}\s*([a-zA-Z\s]+):\s*_{5,}", r"\\vspace{\\stretch{1}}\\\\ \1: \\fillin \\hspace{\\stretch{1}} \2: \\fillin")],
        "custom_space": r"\newpage"
    },
    # Q10: Augmented Matrix
    {
        "type": "single",
        "points": 4,
        "custom_space": r"\vspace{\stretch{1}}"
    },
    # Q11: Row Operations
    {
        "type": "single",
        "points": 6,
        "custom_space": r"\vspace{\stretch{5}}\answerline \newpage"
    },
    # Q12: Domain & Range
    {
        "type": "parts",
        "points": [5, 5],
        "header_prefix": r"\question ",
        "replacements": [(r"domain:\s*_{5,}\s*range:\s*_{5,}", r"\\vspace{\\stretch{1}}\\\\ domain:\\fillin[\\boxed{solution}][2in] \\hspace{\\stretch{1}} range:\\fillin[\\boxed{solution}][2in]")],
        "part_spacing": r"\newpage"
    },
    # Q13: Asymptotes Table
    {
        "type": "single",
        "points": 5,
        "custom_processor": process_asymptotes,
        "custom_space": r"\vspace{\stretch{1}}"
    },
    # Q14: Zeros Table
    {
        "type": "single",
        "points": 10,
        "custom_processor": process_zeros,
        "custom_space": r"\newpage"
    },
    # Q15: Rational Graph
    {
        "type": "single",
        "points": 5,
        "custom_processor": process_rational_graph,
        "custom_space": r"\newpage"
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
        latex_lines.append(fr"{header_prefix} {label_str}")
        
        # Safely escape currency in intro text
        intro_text = escape_currency(parsed_data['intro'])
        latex_lines.append(intro_text + r"\\")
        
        latex_lines.append(r"\begin{parts}")
        
        pts_cfg = config.get("points", [])
        spacing_cfg = config.get("part_spacing", "")
        
        for idx, part in enumerate(parsed_data["parts"]):
            if isinstance(pts_cfg, list) and idx < len(pts_cfg): pts = pts_cfg[idx]
            elif isinstance(pts_cfg, int): pts = pts_cfg
            else: pts = 1
                
            if isinstance(spacing_cfg, list) and idx < len(spacing_cfg): space = spacing_cfg[idx]
            elif isinstance(spacing_cfg, str): space = spacing_cfg
            else: space = ""
            
            # Escape currency dollar signs BEFORE replacements
            part = escape_currency(part)
            
            if 'replacements' in config:
                for (pattern, replacement) in config['replacements']:
                    part = re.sub(pattern, replacement, part, flags=re.DOTALL)
            
            # Clean CheckIt's manual labels
            clean_part = re.sub(r'^(\(\w\)|[\w]\)|[\w]\.)\s*', '', part)
            
            latex_lines.append(fr"    \part[{pts}] {clean_part} {space}")
            
        latex_lines.append(r"\end{parts}")
        
    else:
        pts = config.get("points")
        if pts is not None:
            latex_lines.append(fr"\question[{pts}] {label_str}")
        else:
            latex_lines.append(fr"\question {label_str}")
        
        # Safely escape currency in main text block
        content = escape_currency(parsed_data["content"])
        
        # Apply Custom Processors
        if 'custom_processor' in config:
            content = config['custom_processor'](content)
            
        # Apply Regex Replacements
        if 'replacements' in config:
            for (pattern, replacement) in config['replacements']:
                content = re.sub(pattern, replacement, content, flags=re.DOTALL)
        
        latex_lines.append(content)
        
    if config.get("custom_space"):
        latex_lines.append(config["custom_space"])
        
    if config.get("post_text"):
        latex_lines.append(config["post_text"])
        
    return "\n".join(latex_lines)

def process_checkit_bank(input_filename, output_filename):
    with open(input_filename, "r", encoding="utf-8") as f:
        raw_text = f.read()

    # Safely split the file by CheckIt's item separator
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
            config = { "header": r"\question[5] ", "footer": r" \vspace{\stretch{1}}\\\answerline" }
            
        question_latex = generate_latex_source(parsed, config)
        output_lines.append(question_latex)
                
    # Write Final File
    with open(output_filename, "w", encoding="utf-8") as outfile:
        outfile.write(PREAMBLE)
        outfile.write("\n\n".join(output_lines))
        outfile.write(POSTAMBLE)

    print(f"Success! Processed {len(parsed_items)} questions and saved to {output_filename}")

if __name__ == "__main__":
    process_checkit_bank("CheckIt.tex", "Dept.tex")