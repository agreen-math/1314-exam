from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        
        # 1. Randomize Base
        b_val = choice([2, 3, 4, 5, 6, 7, 8, 9, 'e'])
        b_str = 'e' if b_val == 'e' else str(b_val)
            
        # 2. Randomize linear exponents
        while True:
            # Half the time, generate a simple case (like the screenshot)
            if choice([True, False]):
                c1 = choice([-4, -3, -2, 2, 3, 4])
                c2 = choice([-4, -3, -2, -1, 1, 2, 3, 4])
                d1, d2 = 0, 0
                d3 = randint(1, 3)
            # Half the time, generate a case with constants in the exponents
            else:
                c1 = choice([-3, -2, -1, 1, 2, 3])
                c2 = choice([-3, -2, -1, 1, 2, 3])
                d1 = randint(-4, 4)
                d2 = randint(-4, 4)
                d3 = randint(-4, 4)
            
            # Ensure the x terms don't cancel out so the equation is solvable
            cx = c1 + c2
            if cx != 0:
                break
                
        p1 = c1*x + d1
        p2 = c2*x + d2
        p3 = d3 # Keep RHS exponent a constant
        
        # --- Format RHS ---
        if p3 == 0:
            rhs_str = "1"
        elif p3 == 1:
            rhs_str = b_str
        else:
            rhs_str = f"{b_str}^{{{p3}}}"
            
        # --- Format LHS and Problem ---
        lhs_str = f"{b_str}^{{{latex(p1)}}} \\cdot {b_str}^{{{latex(p2)}}}"
        problem_expr = f"{lhs_str} = {rhs_str}"
        
        # --- Format sum string carefully to avoid ugly "+ -x" situations ---
        p1_str = latex(p1)
        p2_str = latex(p2)
        if p2_str.startswith('-'):
            exp_sum_str = f"{p1_str}{p2_str}"
        else:
            exp_sum_str = f"{p1_str}+{p2_str}"
            
        # --- Build Solution Steps ---
        align_lines = []
        
        # Step 1: Combine bases
        align_lines.append(f"{b_str}^{{{exp_sum_str}}} &= {rhs_str}")
        
        # Step 2: Set exponents equal
        align_lines.append(f"{exp_sum_str} &= {p3}")
        
        # Step 3: Simplify LHS if there were constants to combine
        simp_lhs = cx*x + (d1+d2)
        const_rhs = d3 - d1 - d2
        
        if (d1 + d2) != 0:
            align_lines.append(f"{latex(simp_lhs)} &= {p3}")
            
        # Step 4: Isolate x term
        align_lines.append(f"{latex(cx*x)} &= {const_rhs}")
            
        # Step 5: Solve for x (Fixed SageMath Integer Division)
        ans_x = Integer(const_rhs) / Integer(cx)
        if ans_x.denominator() == 1:
            ans_str = str(ans_x.numerator())
        else:
            # Format negative fractions cleanly
            if ans_x < 0:
                ans_str = f"-\\frac{{{abs(ans_x.numerator())}}}{{{ans_x.denominator()}}}"
            else:
                ans_str = f"\\frac{{{ans_x.numerator()}}}{{{ans_x.denominator()}}}"
                
        align_lines.append(f"x &= {ans_str}")
        
        # Wrap everything in an aligned environment block
        solution_steps = "\\begin{aligned}\n" + " \\\\ \n".join(align_lines) + "\n\\end{aligned}"
        
        return {
            "problem": problem_expr,
            "solution_steps": solution_steps,
            "ans": ans_str
        }