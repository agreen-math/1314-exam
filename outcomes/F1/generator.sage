from sage.all import *
from random import randint, choice, shuffle

class Generator(BaseGenerator):
    def data(self):
        items = []
        
        # 1. Base e, variable exponent
        v1 = choice(['x', 'y', 't'])
        N1 = randint(2, 20)
        items.append({
            "exp": f"e^{{{v1}}} = {N1}",
            "log": f"\\ln({N1}) = {v1}"
        })
        
        # 2. Numeric base, numeric exponent, variable on the left
        b2 = randint(2, 9)
        p2 = randint(2, 5)
        v2 = choice(['r', 'm', 'k'])
        items.append({
            "exp": f"{v2} = {b2}^{{{p2}}}",
            "log": f"\\log_{{{b2}}}({v2}) = {p2}"
        })
        
        # 3. Numeric base, numeric exponent, variable on the right
        b3 = randint(2, 9)
        p3 = randint(2, 5)
        v3 = choice(['y', 'w', 'P'])
        items.append({
            "exp": f"{b3}^{{{p3}}} = {v3}",
            "log": f"\\log_{{{b3}}}({v3}) = {p3}"
        })
        
        # 4. Numeric base, variable exponent, evaluable argument
        b4 = randint(2, 6)
        p4 = randint(2, 4)
        N4 = b4**p4  # Evaluated integer (e.g., 3^3 = 27)
        v4 = choice(['x', 'k', 'n'])
        items.append({
            "exp": f"{b4}^{{{v4}}} = {N4}",
            "log": f"\\log_{{{b4}}}({N4}) = {v4}"
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