from sage.all import *
from random import randint, choice
import math

class Generator(BaseGenerator):
    def data(self):
        # 1. Provide "clean" pairs of (rate_pct, rate_decimal, n_string, n_val, base_eval)
        scenarios = [
            (4, '0.04', 'quarterly', 4, '1.01'),
            (8, '0.08', 'quarterly', 4, '1.02'),
            (6, '0.06', 'semiannually', 2, '1.03'),
            (12, '0.12', 'monthly', 12, '1.01'),
            (5, '0.05', 'quarterly', 4, '1.0125'),
            (10, '0.10', 'semiannually', 2, '1.05')
        ]
        rate_pct, r_dec, n_str, n_val, base_str = choice(scenarios)

        # 2. Randomize Initial Deposit (P)
        P = randint(10, 50) * 100  # $1,000 to $5,000
        
        # 3. Filter target ratios to strictly guarantee t < 20 years
        base_val = float(base_str)
        valid_ratios = []
        for r_val in [1.25, 1.5, 1.75, 2.0, 2.25, 2.5]:
            t_test = math.log(r_val) / (n_val * math.log(base_val))
            if t_test < 20:
                valid_ratios.append(r_val)
                
        # Fallback just in case, though 1.25 will always be under 20 years
        if not valid_ratios:
            valid_ratios = [1.25]

        # Pick the valid ratio and set target A
        ratio_val = choice(valid_ratios)
        A = int(P * ratio_val)

        P_str = f"{P:,}"
        A_str = f"{A:,}"
        
        # 4. Strict SageMath fraction reduction
        frac = Integer(A) / Integer(P)
        if frac.denominator() == 1:
            ratio_tex = f"{frac.numerator()}"
        else:
            ratio_tex = f"\\frac{{{frac.numerator()}}}{{{frac.denominator()}}}"

        # 5. Calculate exact and rounded time
        t_exact = math.log(float(frac)) / (n_val * math.log(base_val))
        t_dec_str = f"{t_exact:.6f}..."
        t_round_str = f"{round(t_exact, 1):.1f}"

        # 6. Build Equation String
        eqn_rhs = f"{P_str} \\left( 1 + \\frac{{{r_dec}}}{{{n_val}}} \\right)^{{{n_val}t}}"
        eqn = f"\\displaystyle{{A(t) = {eqn_rhs}}}"

        # 7. Build Step-by-Step Solution 
        align_lines = []
        align_lines.append(f"{A_str} &= {eqn_rhs}")
        align_lines.append(f"{ratio_tex} &= ({base_str})^{{{n_val}t}}")
        
        # Wrap the ratio in parentheses if it's a fraction to keep it formatted nicely
        if frac.denominator() == 1:
            align_lines.append(f"\\log_{{{base_str}}}({ratio_tex}) &= {n_val}t")
            align_lines.append(f"\\frac{{\\log_{{{base_str}}}({ratio_tex})}}{{{n_val}}} &= t")
        else:
            align_lines.append(f"\\log_{{{base_str}}}\\left({ratio_tex}\\right) &= {n_val}t")
            align_lines.append(f"\\frac{{\\log_{{{base_str}}}\\left({ratio_tex}\\right)}}{{{n_val}}} &= t")
            
        align_lines.append(f"{t_dec_str} &\\approx t")

        solution_steps = "\\begin{aligned}\n" + " \\\\ \n".join(align_lines) + "\n\\end{aligned}"

        return {
            "rate_pct": rate_pct,
            "n_str": n_str,
            "P": P_str,
            "A": A_str,
            "eqn": eqn,
            "solution_steps": solution_steps,
            "t_round": t_round_str
        }