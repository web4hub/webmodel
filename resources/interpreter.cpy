class BefungeInterpreter:
    def __init__(self, code_grid):
        # Pad lines to make a rectangular grid
        max_len = max(len(row) for row in code_grid)
        self.grid = [list(row.ljust(max_len)) for row in code_grid]
        self.height = len(self.grid)
        self.width = max_len
        
        # State
        self.x = 0
        self.y = 0
        self.dx = 1  # 1 = right, -1 = left, 0 = stationary
        self.dy = 0  # 1 = down, -1 = up, 0 = stationary
        self.stack = []
        self.string_mode = False
        self.output = []

    def run(self):
        import random
        
        while True:
            char = self.grid[self.y][self.x]
            
            # Handle String Mode
            if self.string_mode:
                if char == '"':
                    self.string_mode = False
                else:
                    self.stack.append(ord(char))
            else:
                # Normal Instruction Execution
                if '0' <= char <= '9':
                    self.stack.append(int(char))
                elif char == '+':
                    a, b = self.pop(), self.pop()
                    self.stack.append(b + a)
                elif char == '-':
                    a, b = self.pop(), self.pop()
                    self.stack.append(b - a)
                elif char == '*':
                    a, b = self.pop(), self.pop()
                    self.stack.append(b * a)
                elif char == '/':
                    a, b = self.pop(), self.pop()
                    self.stack.append(b // a if a != 0 else 0)
                elif char == '%':
                    a, b = self.pop(), self.pop()
                    self.stack.append(b % a if a != 0 else 0)
                elif char == '!':
                    a = self.pop()
                    self.stack.append(1 if a == 0 else 0)
                elif char == '`':
                    a, b = self.pop(), self.pop()
                    self.stack.append(1 if b > a else 0)
                elif char == '>':
                    self.dx, self.dy = 1, 0
                elif char == '<':
                    self.dx, self.dy = -1, 0
                elif char == '^':
                    self.dx, self.dy = 0, -1
                elif char == 'v':
                    self.dx, self.dy = 0, 1
                elif char == '?':
                    self.dx, self.dy = random.choice([(1,0), (-1,0), (0,1), (0,-1)])
                elif char == '_':
                    self.dx, self.dy = (-1, 0) if self.pop() == 0 else (1, 0)
                elif char == '|':
                    self.dx, self.dy = (0, -1) if self.pop() == 0 else (0, 1)
                elif char == '"':
                    self.string_mode = True
                elif char == ':':
                    self.stack.append(self.stack[-1] if self.stack else 0)
                elif char == '\\':
                    if len(self.stack) >= 2:
                        self.stack[-1], self.stack[-2] = self.stack[-2], self.stack[-1]
                    elif len(self.stack) == 1:
                        self.stack.append(0)
                elif char == '$':
                    self.pop()
                elif char == '.':
                    val = self.pop()
                    self.output.append(str(val))
                elif char == ',':
                    val = self.pop()
                    self.output.append(chr(val))
                elif char == '@':
                    break # End program
            
            # Move the Instruction Pointer (with toroidal wrap-around)
            self.x = (self.x + self.dx) % self.width
            self.y = (self.y + self.dy) % self.height
            
        return "".join(self.output)

    def pop(self):
        return self.stack.pop() if self.stack else 0


# Example Usage: Printing "Hi" using ASCII codes (72 = 'H', 105 = 'i', ! = output char)
code = [
    '72,.i,.@'
]

interpreter = BefungeInterpreter(code)
print("Program Output:", interpreter.run())
