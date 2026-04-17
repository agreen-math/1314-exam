from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize parameters for f(x) = (ax + b) / (c(x - d))
        a = choice([1, 2, 3, 4, 5])
        b = choice([-5, -4, -3, -2, -1, 1, 2, 3, 4, 5])
        c = choice([2, 3, 4, 5])
        d = choice([-5, -4, -3, -2, -1, 1, 2, 3, 4, 5])
        
        # Ensure numerator and denominator don't share a common root
        while a*d + b == 0:  
            b = choice([-5, -4, -3, -2, -1, 1, 2, 3, 4, 5])
        
        # 2. Format the rational expression cleanly
        num_a = "" if a == 1 else str(a)
        num_b = f" + {b}" if b > 0 else f" - {-b}"
        num_str = f"{num_a}x{num_b}"
        
        den_d = f" - {d}" if d > 0 else f" + {-d}"
        den_str = f"{c}(x{den_d})"
        
        expr = f"\\displaystyle{{\\frac{{{num_str}}}{{{den_str}}}}}"
        
        # 3. Calculate and format horizontal asymptote
        frac = Rational(a, c)
        if frac.denominator() == 1:
            ha_val = f"{frac.numerator()}"
        else:
            ha_val = f"\\frac{{{frac.numerator()}}}{{{frac.denominator()}}}"
            
        # 4. Define final answers
        ha_ans = f"y = {ha_val}"
        va_ans = f"x = {d}"
        oa_ans = "\\text{none}"
        
        return {
            "expr": expr,
            "va_ans": va_ans,
            "ha_ans": ha_ans,
            "oa_ans": oa_ans
        }