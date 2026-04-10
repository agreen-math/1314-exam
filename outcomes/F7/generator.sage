from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize parameters (Strictly base 2 or 3)
        b = choice([2, 3])
        
        # 2. Transformations based on reference structure
        A = choice([-1, 2, 3])
        
        H = randint(-8, 8)
        while H == 0: 
            H = randint(-8, 8)
            
        K = randint(-8, 8)
        while K == 0: 
            K = randint(-8, 8)
            
        # 3. Format Expression
        if H > 0:
            inner_str = f"x - {H}" # Shift Right
        else:
            inner_str = f"x + {abs(H)}" # Shift Left
            
        func_part = f"\\log_{{{b}}}({inner_str})"
        
        if A == -1:
            a_str = "-"
        else:
            a_str = f"{A}"
            
        if K > 0:
            k_str = f" + {K}"
        else:
            k_str = f" - {abs(K)}"
            
        expr = f"{a_str}{func_part}{k_str}"
        
        # 4. Table Answers
        h_ref_ans = "NO"
        h_dil_ans = "1"
        
        if H > 0:
            h_trans_dist = f"{H}"
            h_trans_dir = "RIGHT"
        else:
            h_trans_dist = f"{abs(H)}"
            h_trans_dir = "LEFT"
            
        v_ref_ans = "YES" if A < 0 else "NO"
        v_dil_ans = f"{abs(A)}"
        
        if K > 0:
            v_trans_dist = f"{K}"
            v_trans_dir = "UP"
        else:
            v_trans_dist = f"{abs(K)}"
            v_trans_dir = "DOWN"

        # 5. TikZ Graphing Setup
        grid_setup = r"""
            \draw[step=1cm, gray!40, very thin] (-10,-10) grid (10,10);
            \draw[thick, <->] (-10.5,0) -- (10.5,0);
            \draw[thick, <->] (0,-10.5) -- (0,10.5);
        """
        
        # --- Blank Graph ---
        graph_blank = r"\begin{tikzpicture}[scale=0.39]" + grid_setup + r"\end{tikzpicture}"
        
        # --- Solution Graph ---
        graph_sol = r"\begin{tikzpicture}[scale=0.39]" + grid_setup
        graph_sol += r"\clip (-10.5,-10.5) rectangle (10.5,10.5);"
        graph_sol += f"\\draw[dashed, red, thick] ({H}, -10.5) -- ({H}, 10.5);"
        
        # Domain strictly to the right of the asymptote
        domain_start = H + 0.01
        domain_end = 10.5
        
        # TikZ natively uses ln(), so we use the change of base formula
        trans_func_tikz = f"{A} * (ln(\\x - ({H}))/ln({b})) + ({K})"
            
        graph_sol += f"\\draw[blue, very thick, samples=100, domain={domain_start}:{domain_end}, smooth] plot (\\x, {{{trans_func_tikz}}});"
        graph_sol += r"\end{tikzpicture}"

        return {
            "expr": expr,
            "h_ref": h_ref_ans,
            "h_dil": h_dil_ans,
            "h_dist": h_trans_dist,
            "h_dir": h_trans_dir,
            "v_ref": v_ref_ans,
            "v_dil": v_dil_ans,
            "v_dist": v_trans_dist,
            "v_dir": v_trans_dir,
            "graph_blank": graph_blank,
            "graph_sol": graph_sol
        }