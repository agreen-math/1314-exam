from sage.all import *
from random import randint, choice, shuffle

class Generator(BaseGenerator):
    def data(self):
        items = []
        
        # 1. Base n (Small numerical base 2-9)
        b = randint(2, 9)
        y = randint(2, 4)
        x = b**y
        items.append({
            "exp": f"{b}^{{{y}}} = {x}",
            "log": f"\\log_{{{b}}}({x}) = {y}"
        })
        
        # 2. Base e (Natural Log)
        N = randint(10, 99)
        v = choice(['x', 'y', 't'])
        items.append({
            "exp": f"e^{{{v}}} = {N}",
            "log": f"\\ln({N}) = {v}"
        })
        
        # 3. Base 10 (Common Log)
        w = choice(['M', 'N', 'W', 'P'])
        k = choice(['a', 'b', 'c', 'k'])
        items.append({
            "exp": f"10^{{{k}}} = {w}",
            "log": f"\\log({w}) = {k}"
        })
        
        # 4. Symbolic Base
        base_var = choice(['b', 'a', 'm', 'p'])
        arg_var = choice(['A', 'B', 'X', 'Y'])
        ans_var = choice(['c', 'd', 'k', 'n'])
        coeff = randint(1, 4)
        
        if coeff == 1:
            items.append({
                "exp": f"{base_var}^{{{ans_var}}} = {arg_var}",
                "log": f"\\log_{{{base_var}}}({arg_var}) = {ans_var}"
            })
        else:
            # Handles the coefficient twist like 2\log_b(A) = c  ->  b^c = A^2
            items.append({
                "exp": f"{base_var}^{{{ans_var}}} = {arg_var}^{{{coeff}}}",
                "log": f"{coeff}\\log_{{{base_var}}}({arg_var}) = {ans_var}"
            })
            
        # Shuffle the order of the 4 items so the types appear in a random sequence
        shuffle(items)
        
        # Determine which are given as exp and which as log (Guarantee 2 of each)
        given_types = ['exp', 'exp', 'log', 'log']
        shuffle(given_types)
        
        data_dict = {}
        for i in range(4):
            idx = i + 1
            item = items[i]
            g_type = given_types[i]
            
            # Question columns (one is filled, one is blank with spacing)
            if g_type == 'exp':
                data_dict[f"q{idx}_exp"] = item['exp']
                data_dict[f"q{idx}_log"] = r"\hspace{3cm}" 
            else:
                data_dict[f"q{idx}_exp"] = r"\hspace{3cm}"
                data_dict[f"q{idx}_log"] = item['log']
                
            # Answer columns (both filled)
            data_dict[f"a{idx}_exp"] = item['exp']
            data_dict[f"a{idx}_log"] = item['log']
            
        return data_dict