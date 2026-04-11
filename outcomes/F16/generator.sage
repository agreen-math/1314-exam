from sage.all import *
from random import choice, sample
import math

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        found = False
        
        while not found:
            # 1. Randomize minimum degree (3 to 6)
            N = choice([3, 4, 5, 6])
            
            # 2. Pick N distinct roots (avoiding 0 so the y-intercept is clearly positive/negative)
            valid_roots = [-4.5, -4.0, -3.5, -3.0, -2.5, -2.0, -1.5, -1.0, -0.5, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5]
            roots = sample(valid_roots, N)
            roots.sort()
            
            # Ensure distance between roots is at least 1 unit for clearly visible turning points
            good_spacing = True
            for i in range(len(roots)-1):
                if roots[i+1] - roots[i] < 1.0:
                    good_spacing = False
                    break
            if not good_spacing:
                continue
                
            # 3. Base polynomial function for internal calculation
            def base_p(xv):
                res = 1
                for r in roots:
                    res *= (xv - r)
                return res
                
            # 4. Find max extremum height strictly between the outer roots
            x_vals = [roots[0] + i * (roots[-1] - roots[0]) / 200.0 for i in range(201)]
            y_vals = [abs(base_p(xv)) for xv in x_vals]
            max_extremum = max(y_vals)
            
            if max_extremum == 0:
                continue
                
            # 5. Scale to make the graph "humps" stretch beautifully to a height of 5, 6, 7, or 8
            target_height = choice([5, 6, 7, 8])
            lead_sign = choice([-1, 1])
            scale = lead_sign * target_height / float(max_extremum)
            
            # Check y-intercept visibility (Must not be too close to 0 or off the graph)
            y_int = scale * base_p(0)
            if abs(y_int) < 0.5 or abs(y_int) > 9.5:
                continue
                
            found = True

        # --- Generate Answers ---
        deg_ans = "even" if N % 2 == 0 else "odd"
        lead_ans = "positive" if lead_sign > 0 else "negative"
        const_ans = "positive" if y_int > 0 else "negative"
        min_deg_ans = str(N)
        
        # --- TikZ Graphing Setup ---
        # Build function string safely for PGFMath in factored form: scale * (x-r1) * (x-r2)...
        terms = []
        for r in roots:
            val = float(r) # Cast to standard float to drop Sage's heavy precision padding
            if val < 0:
                terms.append(f"(\\x + {abs(val):g})")
            else:
                terms.append(f"(\\x - {val:g})")
                
        trans_func_tikz = f"{scale:.6f} * " + " * ".join(terms)
        
        # Safe Domain Calculation with Arrow Visibility Guarantee:
        # Step outward in fine increments. Stop strictly BEFORE crossing x=10.2 or y=10.2
        # This prevents the final path coordinate from jumping outside the clipping mask.
        safe_min = roots[0]
        step = 0.01
        while safe_min > -10.2:
            if abs(scale * base_p(safe_min - step)) >= 10.2:
                break
            safe_min -= step
                
        safe_max = roots[-1]
        while safe_max < 10.2:
            if abs(scale * base_p(safe_max + step)) >= 10.2:
                break
            safe_max += step
            
        domain_start = round(safe_min, 2)
        domain_end = round(safe_max, 2)
        
        # TikZ graphing code 
        # Clip expanded to 11 to give the physical arrowheads plenty of room to render fully
        graph_tikz = (
            "\\begin{tikzpicture}[scale=0.39]\n"
            "  \\draw[step=1cm, gray!40, very thin] (-10,-10) grid (10,10);\n"
            "  \\draw[thick, <->] (-10.5,0) -- (10.5,0);\n"
            "  \\draw[thick, <->] (0,-10.5) -- (0,10.5);\n"
            "  \\clip (-11,-11) rectangle (11,11);\n"
            f"  \\draw[<->, blue, very thick, samples=150, domain={domain_start}:{domain_end}, smooth] plot (\\x, {{{trans_func_tikz}}});\n"
            "\\end{tikzpicture}"
        )

        # --- Reconstruct Factored Form Function for Instructor Solution ---
        readable_terms = []
        for r in roots:
            val = float(r) # Cast to standard python float so :g formatting strips trailing zeros
            if val < 0:
                readable_terms.append(f"(x + {abs(val):g})")
            else:
                readable_terms.append(f"(x - {val:g})")
                
        # Round scale for readability (0.0123... vs 0.0123)
        scale_rounded = round(float(scale), 4)
        equation_latex = f"{scale_rounded:g}" + "".join(readable_terms)

        return {
            "graph_tikz": graph_tikz,
            "equation_latex": equation_latex,
            "deg_ans": deg_ans,
            "lead_ans": lead_ans,
            "const_ans": const_ans,
            "min_deg_ans": min_deg_ans
        }