from sage.all import *
from random import randint, choice, sample

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize Contexts
        contexts = [
            ("A concert venue", "student tickets", "general admission tickets", "student ticket", "general admission ticket", "s", "g"),
            ("A bakery", "loaves of bread", "pies", "loaf of bread", "pie", "b", "p"),
            ("A coffee shop", "lattes", "muffins", "latte", "muffin", "l", "m"),
            ("A local farm", "baskets of apples", "baskets of peaches", "basket of apples", "basket of peaches", "a", "p")
        ]
        setting, plural1, plural2, sing1, sing2, v1, v2 = choice(contexts)

        # 2. Randomize Prices
        p1 = randint(4, 15)
        p2 = randint(10, 25)
        while p1 == p2:
            p2 = randint(10, 25)

        # 3. Randomize Quantities
        A = choice([10, 20, 30, 40, 50])
        B, C = sorted(sample([5, 10, 15, 20, 25, 30], 2))

        # 4. Calculate Totals
        T1 = A * p1 + B * p2
        T2 = A * p1 + C * p2

        # 5. Build Problem String (Removed backslashes before $)
        problem = f"{setting} is selling {plural1} and {plural2}. On the first day of sales, they sold {A} {plural1} and {B} {plural2} for a total of ${T1}. They took in ${T2} for {A} {plural1} and {C} {plural2} on the second day. Find the price of each type of item."

        # 6. Build Solution Steps
        align_lines = []
        align_lines.append(f"\\text{{Let }} {v1} &\\text{{ = price of {sing1}}}")
        align_lines.append(f"\\text{{Let }} {v2} &\\text{{ = price of {sing2}}}")
        align_lines.append(f"")
        align_lines.append(f"{A}{v1} + {B}{v2} &= {T1}")
        align_lines.append(f"{A}{v1} + {C}{v2} &= {T2}")
        align_lines.append(f"")
        align_lines.append(f"\\text{{Subtract equations:}} &")
        align_lines.append(f"{C - B}{v2} &= {T2 - T1}")
        align_lines.append(f"{v2} &= {p2}")
        align_lines.append(f"")
        align_lines.append(f"\\text{{Substitute back:}} &")
        align_lines.append(f"{A}{v1} + {B}({p2}) &= {T1}")
        align_lines.append(f"{A}{v1} + {B*p2} &= {T1}")
        align_lines.append(f"{A}{v1} &= {T1 - B*p2}")
        align_lines.append(f"{v1} &= {p1}")

        solution_steps = "\\begin{aligned}\n" + " \\\\ \n".join(align_lines) + "\n\\end{aligned}"

        return {
            "problem": problem,
            "sing1": sing1,
            "sing2": sing2,
            "solution_steps": solution_steps,
            "ans1": str(p1),
            "ans2": str(p2)
        }