# BULLY-lang
Bully is Ugly Little Language Yerk.

## NOTE: Interpreter wasn't writen yet, so for now enjoy this README.

### Compilation

You need to have Chicken Scheme installed.
Under linux run in code directory:

```
make bully 
```

### Usage

#### What is BULLY?

BULLY is a multi-stack based language. It's different from FORTH in that you can make new stack and all instructions can read/write from/to one or more stacks.

"BULLY:> " is default interpreter prompt.

#### Syntax

General form:

```
[in-stack-1 in-stack-2 ... in-stack-n > command > out-stack-1 ... out-stack-n]

Example:
[s1 s2 > PUSH > s3 s4]

```

Commands read values from in-stacks and write to out-stacks.

If there is only one in-stack and only one out-stack you can omit "[]":

```
in-stack > command > out-stack

Example:
d > PUSH > o
```

If no in-stack is specified command reads from i (input), so it reads values to it's left. If no out-stack is specified, values are writen to o (output) and displayed.

```
value-1 value-2 ... value-3 command

Examples:
1 2 PUSH
1 2 PUSH > d
d > PUSH
```

#### Commands

##### Numeric:

ADD   - adds all numbers from in-stacks and pushes them to out-stacks.

SUB   - substracts all numbers from in-stacks and pushes them to out-stacks. When called with only one value it negates it.

MUL   - multiplies all numbers from in-stacks and pushes them to out-stacks.

DIV   - divides all numbers from in-stacks and pushes them to out-stacks. When called with only one value it returns it's reciprocal.

##### Stack manipulation:

SWAP  - Can only be called by a single in-stack. It copies two values from in-stack, swaps them and pushes them to out-stacks.
COMP  - Can only be called by a single in-stack. It copies two values from in-stack, and if they are same pushes 1 to out-stacks, else it pushes FALSE.

##### Miscellanous:

PUSH  - copies values from in-stacks and pushes them to out-stacks.

POP   - removes values from in-stacks and pushes them to out-stacks.

STACK - makes new stacks with values from in-stacks and named as specified in out-stacks. Values are pushed to new stacks from in-stacks in order from left to right.

IF    - reads three values from single in-stack. If first is true, second is pushed to out-stacks, otherwise third is pushed.

DELAY - reads values from in-stacks and associates them with out-stacks.

FORCE - pushes delayed values to their associated out-stacks. Both in-stacks and out-stacks are used to determine which values to force. For example, [s1 s2 > FORCE > d o] will force values associated with s1, s2, d, o.

All commands copy values from in-stacks (except POP). If you want to pop these
values instead, use command-name! (example: DIV!). There is no PUSH!, since
PUSH! is POP. Also there is no FORCE!.

#### Data Types

Numbers - anything chicken scheme interprets as a number, all numbers are true (not FALSE).

FALSE 	- boolean false

Stacks	- Fundamental data type. These are last-in first-out stacks. This basically means that the first value pushed to stack will be the last one read. Pushing means adding a new value to stack, while popping means removing it. These commands are a little different in BULLY (check PUSH and POP above) since all commands can read from stacks and write to them.

#### Default Stacks

d - default stack, only stack not initialized by user.

i - isn't a stack. If i is specified as in-stack, command will read values from its left (for example, PUSH here reads 1 2 3: 1 2 3 i > PUSH > d). If no in-stack is specified, i is used.

o - isn't a stack. If o is specified as out-stack, values sent to it will be displayed to the user. If no out-stack is specified, o is used. There is no PRINT or DISPLAY command, PUSH values to out-stack instead.
