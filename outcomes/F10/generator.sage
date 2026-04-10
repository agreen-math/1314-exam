from sage.all import *
from random import randint, choice, sample

class Generator(BaseGenerator):
    def data(self):
        def fmt_term(coeff, var=""):
            if coeff == 1 and var != "": return var
            if coeff == -1 and var != "": return "-" + var
            return f"{coeff}{var}"

        def combine_terms(*terms):
            res = ""
            for i, t in enumerate(terms):
                if i == 0:
                    res += t
                else:
                    if t.startswith('-'):
                        res += f" - {t[1:]}"
                    else:
                        res += f" + {t}"
            return res
        
        def non_zero_rand(min_v, max_v):
            v = 0
            while v == 0: v = randint(min_v, max_v)
            return v

        a1 = non_zero_rand(-25, 25)
        b1 = non_zero_rand(-25, 25)
        c1 = non_zero_rand(-25, 25)
        a2 = non_zero_rand(-25, 25)
        b2 = non_zero_rand(-25, 25)
        c2 = non_zero_rand(-25, 25)

        formats = sample([1, 2, 3, 4, 5], 2)

        def get_eq(a, b, c, form_type):
            if form_type == 1:
                lhs = "0"
                rhs = combine_terms(fmt_term(-b, "y"), fmt_term(c), fmt_term(-a, "x"))
            elif form_type == 2:
                lhs = combine_terms(fmt_term(c), fmt_term(-b, "y"))
                rhs = fmt_term(a, "x")
            elif form_type == 3:
                lhs = combine_terms(fmt_term(-a, "x"), fmt_term(c))
                rhs = fmt_term(b, "y")
            elif form_type == 4:
                lhs = fmt_term(b, "y")
                rhs = combine_terms(fmt_term(c), fmt_term(-a, "x"))
            elif form_type == 5:
                lhs = combine_terms(fmt_term(a, "x"), fmt_term(-c))
                rhs = fmt_term(-b, "y")
            return f"{lhs} = {rhs}"

        prob_eq1 = get_eq(a1, b1, c1, formats[0])
        prob_eq2 = get_eq(a2, b2, c2, formats[1])

        system_str = f"\\begin{{aligned}}\n{prob_eq1.replace('=', '&=')} \\\\\n{prob_eq2.replace('=', '&=')}\n\\end{{aligned}}"

        std_eq1 = f"{combine_terms(fmt_term(a1, 'x'), fmt_term(b1, 'y'))} &= {c1}"
        std_eq2 = f"{combine_terms(fmt_term(a2, 'x'), fmt_term(b2, 'y'))} &= {c2}"
        std_system_str = f"\\begin{{aligned}}\n{std_eq1} \\\\\n{std_eq2}\n\\end{{aligned}}"

        matrix_str = f"\\left[\\begin{{array}}{{cc|c}}\n{a1} & {b1} & {c1} \\\\\n{a2} & {b2} & {c2}\n\\end{{array}}\\right]"

        return {
            "system": system_str,
            "std_system": std_system_str,
            "matrix": matrix_str
        }