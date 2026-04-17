from sage.all import *
from random import randint, choice, sample, shuffle

class Generator(BaseGenerator):
    def data(self):
        # ---------------------------------------------------------
        # PART (a): Expansion
        # ---------------------------------------------------------
        b = choice([2, 3, 5])
        
        # Pick powers for the constants so they evaluate cleanly
        m = randint(2, 4)
        n = randint(1, 2)
        while m <= n:
            m = randint(2, 4)
            
        A = b**m
        B = b**n
        
        # Pick variables and exponents
        v1, v2 = sample(['x', 'y', 'z', 'w'], 2)
        p = randint(2, 4)
        q = randint(1, 3)
        
        q_str = f"^{{{q}}}" if q > 1 else ""
        
        # Construct expressions
        expr_a = f"\\displaystyle{{\\log_{{{b}}}\\left( \\frac{{{A}{v1}^{{{p}}}}}{{{B}{v2}{q_str}}} \\right)}}"
        
        q_log_str = f"{q}\\log_{{{b}}}({v2})" if q > 1 else f"\\log_{{{b}}}({v2})"
        
        # Step-by-step solutions
        step1_a = f"\\log_{{{b}}}({A}) + {p}\\log_{{{b}}}({v1}) - \\log_{{{b}}}({B}) - {q_log_str}"
        step2_a = f"{m} + {p}\\log_{{{b}}}({v1}) - {n} - {q_log_str}"
        ans_a = f"{m-n} + {p}\\log_{{{b}}}({v1}) - {q_log_str}"
        
        
        # ---------------------------------------------------------
        # PART (b): Condensation
        # ---------------------------------------------------------
        base_func = choice([r"\ln", r"\log"])
        v_rad, v_norm, v_split = sample(['x', 'y', 'z', 'a', 'b', 'c'], 3)
        
        # 1. Fractional term (radical)
        rad_idx = choice([2, 3])
        rad_sign = choice([-1, 1])
        
        # 2. Normal integer term
        c_norm = choice([-4, -3, -2, 2, 3, 4])
        
        # 3. Split terms (two terms that combine into one)
        c_split_total = choice([-3, -2, -1, 1, 2, 3])
        c_split1 = randint(1, 4) if choice([True, False]) else randint(-4, -1)
        c_split2 = c_split_total - c_split1
        while c_split2 == 0:
            c_split1 = randint(1, 4) if choice([True, False]) else randint(-4, -1)
            c_split2 = c_split_total - c_split1
            
        components = [
            {'var': v_rad, 'sign': rad_sign, 'abs_val': 1, 'is_rad': True, 'rad_idx': rad_idx},
            {'var': v_norm, 'sign': 1 if c_norm > 0 else -1, 'abs_val': abs(c_norm), 'is_rad': False},
            {'var': v_split, 'sign': 1 if c_split1 > 0 else -1, 'abs_val': abs(c_split1), 'is_rad': False},
            {'var': v_split, 'sign': 1 if c_split2 > 0 else -1, 'abs_val': abs(c_split2), 'is_rad': False}
        ]
        shuffle(components)
        
        expr_b = ""
        step1_b = ""
        num_factors = []
        den_factors = []
        
        for i, comp in enumerate(components):
            sign = comp['sign']
            var = comp['var']
            abs_val = comp['abs_val']
            is_rad = comp['is_rad']
            
            # --- Format original expression term ---
            if abs_val == 1 and not is_rad:
                coeff_str = ""
            elif is_rad:
                coeff_str = f"\\displaystyle{{\\frac{{1}}{{{comp['rad_idx']}}}}}"
            else:
                coeff_str = str(abs_val)
                
            term_str = f"{coeff_str}{base_func} {var}"
            
            if sign > 0:
                if i == 0: expr_b += term_str
                else: expr_b += f" + {term_str}"
            else:
                if i == 0: expr_b += f"-{term_str}"
                else: expr_b += f" - {term_str}"
                    
            # --- Format Step 1 term (Powers inside logs) ---
            if abs_val == 1 and not is_rad:
                pow_str = var
            elif is_rad:
                pow_str = f"{var}^{{1/{comp['rad_idx']}}}"
            else:
                pow_str = f"{var}^{{{abs_val}}}"
                
            step1_term = f"{base_func}({pow_str})"
            if sign > 0:
                if i == 0: step1_b += step1_term
                else: step1_b += f" + {step1_term}"
            else:
                if i == 0: step1_b += f"-{step1_term}"
                else: step1_b += f" - {step1_term}"

            # --- Format Step 2 factors (Unsimplified single fraction) ---
            if is_rad:
                factor_str = f"\\sqrt{{{var}}}" if comp['rad_idx'] == 2 else f"\\sqrt[{comp['rad_idx']}]{{{var}}}"
            else:
                factor_str = f"{var}^{{{abs_val}}}" if abs_val != 1 else var
                
            if sign > 0:
                num_factors.append(factor_str)
            else:
                den_factors.append(factor_str)
                
        # Sort factors alphabetically for the step 2 display
        num_factors.sort()
        den_factors.sort()
        
        num_str = " ".join(num_factors) if num_factors else "1"
        den_str = " ".join(den_factors) if den_factors else "1"
        
        if den_str == "1":
            step2_b = f"{base_func}\\left(\\displaystyle{{ {num_str} }}\\right)"
        else:
            step2_b = f"{base_func}\\left(\\displaystyle{{\\frac{{{num_str}}}{{{den_str}}}}}\\right)"
            
        # --- Final Answer Formatting (Simplified Fraction) ---
        ans_num = []
        ans_den = []
        
        if rad_sign > 0:
            ans_num.append(f"\\sqrt{{{v_rad}}}" if rad_idx == 2 else f"\\sqrt[{rad_idx}]{{{v_rad}}}")
        else:
            ans_den.append(f"\\sqrt{{{v_rad}}}" if rad_idx == 2 else f"\\sqrt[{rad_idx}]{{{v_rad}}}")
            
        if c_norm > 0: 
            ans_num.append(f"{v_norm}" if c_norm == 1 else f"{v_norm}^{{{c_norm}}}")
        else: 
            ans_den.append(f"{v_norm}" if -c_norm == 1 else f"{v_norm}^{{{-c_norm}}}")
            
        if c_split_total > 0: 
            ans_num.append(f"{v_split}" if c_split_total == 1 else f"{v_split}^{{{c_split_total}}}")
        elif c_split_total < 0: 
            ans_den.append(f"{v_split}" if -c_split_total == 1 else f"{v_split}^{{{-c_split_total}}}")
        
        ans_num.sort()
        ans_den.sort()
        
        ans_num_str = " ".join(ans_num) if ans_num else "1"
        ans_den_str = " ".join(ans_den) if ans_den else "1"
        
        if ans_den_str == "1":
            ans_b = f"{base_func}\\left(\\displaystyle{{ {ans_num_str} }}\\right)"
        else:
            ans_b = f"{base_func}\\left(\\displaystyle{{\\frac{{{ans_num_str}}}{{{ans_den_str}}}}}\\right)"
            
        return {
            "expr_a": expr_a,
            "step1_a": step1_a,
            "step2_a": step2_a,
            "ans_a": ans_a,
            "expr_b": expr_b,
            "step1_b": step1_b,
            "step2_b": step2_b,
            "ans_b": ans_b
        }