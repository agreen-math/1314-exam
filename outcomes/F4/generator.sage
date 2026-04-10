from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        
        while True:
            # 1. Randomize parameters
            b = choice([2, 3, 4, 5, 6])
            k = choice([1, 2])
            R = b**k
            
            c = randint(-6, 6)
            d = randint(-6, 6)
            
            # Keep the two log arguments distinct
            if c == d: 
                continue
                
            # 2. Build the resulting quadratic: x^2 + (c+d)x + (cd - R) = 0
            B = c + d
            C = c * d - R
            disc = B**2 - 4*C
            
            # Ensure it factors nicely with real integer roots
            if disc < 0: 
                continue
            if not Integer(disc).is_square(): 
                continue
                
            sq = Integer(disc).sqrt()
            if (B + sq) % 2 != 0: 
                continue
                
            r1 = (-B + sq) // 2
            r2 = (-B - sq) // 2
            
            # 3. Check against the domain of the original logs
            # Arguments must be strictly greater than 0
            r1_valid = (r1 + c > 0) and (r1 + d > 0)
            r2_valid = (r2 + c > 0) and (r2 + d > 0)
            
            # We explicitly want exactly one valid and one extraneous solution
            if r1_valid and not r2_valid:
                sol = r1
                ext = r2
                break
            elif r2_valid and not r1_valid:
                sol = r2
                ext = r1
                break
                
        # --- Format Expressions ---
        log_b = f"\\log_{{{b}}}"
        arg1 = x + c
        arg2 = x + d
        
        problem = f"{log_b}({latex(arg1)}) + {log_b}({latex(arg2)}) = {k}"
        
        # Format the combined product cleanly (e.g., x(x-1) instead of (x)(x-1))
        if c == 0:
            prod_str = f"x({latex(arg2)})"
        elif d == 0:
            prod_str = f"x({latex(arg1)})"
        else:
            prod_str = f"({latex(arg1)})({latex(arg2)})"
            
        expanded_rhs = x**2 + B*x + c*d
        quad_expr = x**2 + B*x + C
        
        factor1 = x - sol
        factor2 = x - ext
        
        # --- Build Solution Steps ---
        align_lines = []
        align_lines.append(f"{log_b}({prod_str}) &= {k}")
        align_lines.append(f"{R} &= {prod_str}")
        
        # Show the distribution step
        align_lines.append(f"{R} &= {latex(expanded_rhs)}")
        
        # Set to zero and factor
        align_lines.append(f"0 &= {latex(quad_expr)}")
        align_lines.append(f"0 &= ({latex(factor1)})({latex(factor2)})")
        
        solution_steps = "\\begin{aligned}\n" + " \\\\ \n".join(align_lines) + "\n\\end{aligned}"
        
        return {
            "problem": problem,
            "solution_steps": solution_steps,
            "ans_sol": f"x = {sol}",
            "ans_ext": f"x = {ext}"
        }