# BULLY-lang
Bully is Ugly Little Language Yerk.

## NOTE: Interpreter still has some bugs and is unfinished... But should mostly work.

### Compilation

You need to have Chicken Scheme installed.
Under linux run in code directory:

```
csc -o interpreter interpreter.scm
```

And then

```
./interpreter
```

to start BULLY interpreter.

### Usage

#### What is BULLY?

BULLY is a stack oriented language with explicit stack manipulation

#### Tutorial

Syntax:

```
in-stack: values-to-be-writen-to-in-stack out-stack command .
```

Example:

```
d: 1 2 3 o PUSH .
```

All values between "in-stack:" and "." are pushed to in-stack. "." executes last item of stack, in this case, command PUSH, which works on values of in-stack. Last value between command is regarded by most commands as out-stacks, where results are pushed.

Three stacks are predefined: "i" "o" and "d". "o" stack is for output and will be displayed to user and emptied after evaluation.

You can use multiple commands at a time:

```
d: 1 2 3 o PUSH . 1 2 o POP .
```

"o" stack will be displayed after last command is executed. All commands work on same in-stack.

O is false, all other values are true. This mostly only matters when using IF command.

#### Commands

##### Numeric:

ADD   - adds all numbers from in-stack and pushes result to out-stack.

SUB   - substracts all numbers from in-stack and pushes result to out-stack. When called with only one value it negates it.

MUL   - multiplies all numbers from in-stack and pushes result to out-stack.

DIV   - divides all numbers from in-stack and pushes result to out-stack. When called with only one value it returns it's reciprocal.

Numeric commands pop item from in-stack, so it's empty after usage. Of course you can push result back to in-stack.

Example (displays 9):

```
d: 1 2 d ADD . 3 o MUL .
```

##### Stack manipulation:

SWAP  - It pops two values from in-stack, swaps them and pushes them to out-stack.

COMP  - It pops two values from in-stack, and if they are same pushes 1 to out-stack, else it pushes 0.

DUP   - It pops a value from in-stack adn pushes it twice to out-stack.

##### Miscellanous:

PUSH  - copies values from in-stack and pushes them to out-stack.

POP   - pops values from in-stack and pushes them to out-stack.

@     - makes new stacks named after values it pops from in-stack. For now only single character names are allowed (s, m, n, but not s1, s2, s3 (this is a bug and will soon be fixed)).

IF    - reads three values from in-stack. If first is true, second is pushed to out-stacks, otherwise third is pushed.

DELAY - needs even number of arguments from in-stack. First argument of a pair should be value, second stack it targets. DELAYed values can be FORCE pushed to targeted stacks.

FORCE - pushes all delayed values to their associated out-stacks.

Example (1 and 2 are displayed, 3 is pushed to i stack):

```
d: 1 o 2 o 3 i DELAY .
i: FORCE .
```
