from sage.all import *
from random import randint, choice, sample

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize the Base
        base_type = choice(['log', 'ln', 'custom'])
        if base_type == 'log':
            log_fmt = r"\log"
        elif base_type == 'ln':
            log_fmt = r"\ln"
        else:
            b = choice([2, 3, 4, 5, 'a', 'b', 'c'])
            log_fmt = f"\\log_{{{b}}}"

        # 2. Randomize the Arguments (Single terms with coefficients)
        v1, v2 = sample(['x', 'y', 'w', 'z'], 2)
        m = randint(2, 8)
        n = randint(2, 8)
        
        A = f"{m}{v1}"
        B = f"{n}{v2}"
        
        # 3. Pick the Error Scenario
        error_type = choice(['quotient', 'product', 'power'])
        
        if error_type == 'quotient':
            # Prompt: log(A) - log(B)
            original_expr = f"{log_fmt}({A}) - {log_fmt}({B})"
            # Mistake: log(A) / log(B)
            mistake_expr = f"\\dfrac{{{log_fmt}({A})}}{{{log_fmt}({B})}}"
            # Correct: log(A / B)
            correct_expr = f"{log_fmt}\\left(\\dfrac{{{A}}}{{{B}}}\\right)"
            
        elif error_type == 'product':
            # Prompt: log(A) + log(B)
            original_expr = f"{log_fmt}({A}) + {log_fmt}({B})"
            # Mistake: log(A) * log(B)
            mistake_expr = f"{log_fmt}({A}) \\cdot {log_fmt}({B})"
            # Correct: log(A * B)
            correct_expr = f"{log_fmt}({m*n}{v1}{v2})"
            
        else: 
            # Power Error Scenario
            c = randint(2, 4)
            # Prompt: log(A^c)
            original_expr = f"{log_fmt}\\left(({A})^{{{c}}}\\right)"
            # Mistake: log(c * A) (Unsimplified to show the error source)
            mistake_expr = f"{log_fmt}({c} \\cdot {A})"
            # Correct: c * log(A)
            correct_expr = f"{c} {log_fmt}({A})"

        return {
            "original_expr": original_expr,
            "mistake_expr": mistake_expr,
            "correct_expr": correct_expr
        }