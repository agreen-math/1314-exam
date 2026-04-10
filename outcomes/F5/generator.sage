from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize Base
        b = choice([2, 3, 4, 5, 6, 7, 8, 9, 'e'])
        if b == 'e':
            log_b = r"\ln"
        else:
            log_b = f"\\log_{{{b}}}"
            
        # 2. Pick coefficients and the final solution k
        c1 = randint(2, 8)
        c2 = randint(2, 8)
        k = randint(2, 6) # The answer will be x = +/- k
        
        # Calculate RHS argument
        R = c1 * c2 * (k**2)
        
        # 3. Randomize the order of the terms on the LHS
        if choice([True, False]):
            term1 = f"{c1}"
            term2 = f"{c2}x^2"
            prod_str = f"{c1} \\cdot {c2}x^2"
        else:
            term1 = f"{c2}x^2"
            term2 = f"{c1}"
            prod_str = f"{c2}x^2 \\cdot {c1}"
            
        problem = f"{log_b}({term1}) + {log_b}({term2}) = {log_b}({R})"
        
        # 4. Build Solution Steps
        align_lines = []
        align_lines.append(f"{log_b}({prod_str}) &= {log_b}({R})")
        align_lines.append(f"{c1*c2}x^2 &= {R}")
        align_lines.append(f"x^2 &= {k**2}")
        align_lines.append(f"x &= \\pm {k}")
        
        solution_steps = "\\begin{aligned}\n" + " \\\\ \n".join(align_lines) + "\n\\end{aligned}"
        
        return {
            "problem": problem,
            "solution_steps": solution_steps,
            "ans_sol": f"x = \\pm {k}",
            "ans_ext": "\\text{none}"
        }