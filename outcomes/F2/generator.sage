from sage.all import *
from random import randint, choice, sample

class Generator(BaseGenerator):
    def data(self):
        # Pick a symbolic base
        base = choice(['a', 'b', 'c', 'x', 'y'])

        # Pick variables for the argument
        v1, v2 = sample(['m', 'n', 'p', 'q', 'w', 'z'], 2)

        # Pick exponents
        p1 = randint(2, 5)
        p2 = choice([1, 2, 3])

        # Pick radical components
        N = randint(2, 30)
        r = randint(2, 5)

        # Format radical properly (hide index if square root)
        if r == 2:
            rad_str = f"\\sqrt{{{N}}}"
            frac_str = "1/2"
            latex_frac = "\\frac{1}{2}"
        else:
            rad_str = f"\\sqrt[{r}]{{{N}}}"
            frac_str = f"1/{r}"
            latex_frac = f"\\frac{{1}}{{{r}}}"

        # Format variable 2 (hide exponent if 1)
        v2_str = f"{v2}^{{{p2}}}" if p2 > 1 else f"{v2}"

        # Randomize structure (Radical on top vs Radical on bottom)
        structure = choice(['rad_top', 'rad_bot'])

        if structure == 'rad_top':
            arg_latex = f"\\frac{{{rad_str}}}{{{v1}^{{{p1}}} {v2_str}}}"

            # Step 1: log(rad) - log(v1^p1) - log(v2^p2)
            step1 = f"\\log_{{{base}}}({N}^{{{frac_str}}}) - \\log_{{{base}}}({v1}^{{{p1}}}) - \\log_{{{base}}}({v2_str})"

            # Step 2: powers to front
            ans_term1 = f"{latex_frac} \\log_{{{base}}}({N})"
            ans_term2 = f"- {p1} \\log_{{{base}}}({v1})"
            ans_term3 = f"- {p2} \\log_{{{base}}}({v2})" if p2 > 1 else f"- \\log_{{{base}}}({v2})"
            final_ans = f"{ans_term1} {ans_term2} {ans_term3}"

        else:
            arg_latex = f"\\frac{{{v1}^{{{p1}}} {v2_str}}}{{{rad_str}}}"

            # Step 1: log(v1^p1) + log(v2^p2) - log(rad)
            step1 = f"\\log_{{{base}}}({v1}^{{{p1}}}) + \\log_{{{base}}}({v2_str}) - \\log_{{{base}}}({N}^{{{frac_str}}})"

            # Step 2: powers to front
            ans_term1 = f"{p1} \\log_{{{base}}}({v1})"
            ans_term2 = f"+ {p2} \\log_{{{base}}}({v2})" if p2 > 1 else f"+ \\log_{{{base}}}({v2})"
            ans_term3 = f"- {latex_frac} \\log_{{{base}}}({N})"
            final_ans = f"{ans_term1} {ans_term2} {ans_term3}"

        problem = f"\\log_{{{base}}}\\left( {arg_latex} \\right)"

        return {
            "problem": problem,
            "step1": step1,
            "final_ans": final_ans
        }