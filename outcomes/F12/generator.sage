from sage.all import *
from random import randint

class Generator(BaseGenerator):
    def data(self):
        # 1. Generate integer solutions
        x = randint(-9, 9)
        y = randint(-9, 9)

        # 2. Set parameters to strictly enforce a 4-step Gauss-Jordan elimination with no fractions
        c = 1  # Bottom left must be 1 so a simple row swap guarantees a leading 1
        
        a = 0
        while a in [0, 1, -1]:
            a = randint(-6, 6)
            
        d = 0
        while d == 0:
            d = randint(-5, 5)
            
        k = 0
        while k in [0, 1, -1]:
            k = randint(-6, 6)
            
        # 3. Calculate remaining matrix elements backwards from the solution
        b = k + a * d
        f = x + d * y
        e = a * x + b * y
        
        # --- Matrix String Definitions ---
        M0 = f"\\left[\\begin{{array}}{{cc|c}}\n{a} & {b} & {e} \\\\\n{c} & {d} & {f}\n\\end{{array}}\\right]"
        M1 = f"\\left[\\begin{{array}}{{cc|c}}\n{c} & {d} & {f} \\\\\n{a} & {b} & {e}\n\\end{{array}}\\right]"
        M2 = f"\\left[\\begin{{array}}{{cc|c}}\n{c} & {d} & {f} \\\\\n0 & {k} & {k*y}\n\\end{{array}}\\right]"
        M3 = f"\\left[\\begin{{array}}{{cc|c}}\n{c} & {d} & {f} \\\\\n0 & 1 & {y}\n\\end{{array}}\\right]"
        M4 = f"\\left[\\begin{{array}}{{cc|c}}\n1 & 0 & {x} \\\\\n0 & 1 & {y}\n\\end{{array}}\\right]"
        
        # --- Operation String Definitions ---
        op1 = "R_1 \\leftrightarrow R_2"
        
        if a > 0:
            op2 = f"R_2 - {a}R_1 \\to R_2"
        else:
            op2 = f"R_2 + {-a}R_1 \\to R_2"
            
        op3 = f"\\frac{{R_2}}{{{k}}} \\to R_2"
        
        if d > 0:
            op4 = f"R_1 - {d}R_2 \\to R_1"
        else:
            op4 = f"R_1 + {-d}R_2 \\to R_1"
            
        # --- Build Aligned Solution Steps ---
        solution_steps = (
            f"\\begin{{aligned}}\n"
            f"& {M0} \\\\\n"
            f"\\xrightarrow{{{op1}}} & {M1} \\\\\n"
            f"\\xrightarrow{{{op2}}} & {M2} \\\\\n"
            f"\\xrightarrow{{{op3}}} & {M3} \\\\\n"
            f"\\xrightarrow{{{op4}}} & {M4}\n"
            f"\\end{{aligned}}"
        )
        
        return {
            "initial_matrix": M0,
            "solution_steps": solution_steps,
            "ans": f"({x}, {y})"
        }