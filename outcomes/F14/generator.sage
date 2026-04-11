from sage.all import *
from random import choice
import math

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        
        # 1. Parameter Constraints
        # a is an integer greater than 1
        a = choice([2, 3, 4, 5])
        
        # d is either 1 or -1
        d = choice([-1, 1])
        
        # b is a nonzero integer. Ensure gcd(a,b)=1 and roots don't overlap (-b/a != -d)
        b = choice([-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7])
        while b == 0 or math.gcd(abs(a), abs(b)) != 1 or b == a * d:
            b = choice([-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7])
            
        # 2. Build the factors: x^2 (ax + b)(x + d)
        p1 = x**2
        p2 = a*x + b
        p3 = x + d
        
        poly = expand(p1 * p2 * p3)
        
        # 3. Build zeros data
        roots_info = []
        def add_root(num, den, m):
            behavior = "bounce" if m % 2 == 0 else "cross"
            # Using Sage Integers to force proper fraction creation
            val_frac = Integer(num) / Integer(den)
            roots_info.append({
                "zero": latex(val_frac),
                "mult": str(m),
                "behavior": behavior,
                "val": float(num) / float(den)
            })

        add_root(0, 1, 2)       # From x^2
        add_root(-b, a, 1)      # From (ax + b)
        add_root(-d, 1, 1)      # From (x + d)
            
        # Sort roots from left to right on the number line
        roots_info.sort(key=lambda item: item["val"])
        
        # 4. Format table rows
        blank_rows = ""
        for _ in range(5):
            blank_rows += "                    \\rule[-1.2em]{0pt}{3em} & & \\\\ \\hline\n"
            
        sol_rows = ""
        for info in roots_info:
            sol_rows += f"                    \\rule[-1.2em]{{0pt}}{{3em}} {info['zero']} & {info['mult']} & \\text{{{info['behavior']}}} \\\\ \\hline\n"
        for _ in range(5 - len(roots_info)):
            sol_rows += "                    \\rule[-1.2em]{0pt}{3em} & & \\\\ \\hline\n"
            
        # 5. Format factorization steps for the solution
        def format_factor(coeff, const):
            term = ""
            if coeff == 1: term = "x"
            elif coeff == -1: term = "-x"
            else: term = f"{coeff}x"
            
            if const > 0: term += f" + {const}"
            elif const < 0: term += f" - {-const}"
            
            return f"({term})"
            
        f2_str = format_factor(a, b)
        f3_str = format_factor(1, d)
        f1_str = "x^2"
        
        step2_str = f"{f1_str}{f2_str}{f3_str}"
        quad_expr = expand((a*x + b) * (x + d))
        step1_str = f"{f1_str}({latex(quad_expr)})"
        
        steps = f"\\begin{{aligned}}\nf(x) &= {latex(poly)} \\\\\n&= {step1_str} \\\\\n&= {step2_str}\n\\end{{aligned}}"
        
        return {
            "poly": latex(poly),
            "blank_rows": blank_rows,
            "sol_rows": sol_rows,
            "steps": steps
        }