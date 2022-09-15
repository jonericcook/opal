## Senior Software Engineer @ Opal | Take-Home Coding Assignment - Solution

### Instructions

Please enter the following instructions in your terminal:

1. `git clone git@github.com:jonericcook/opal.git`
2. `cd opal`
3. `iex -S mix`

Now you are ready to start entering commands 🤙

### Note

To get a look at the underlying state simply enter `state` at anytime.

### Example

```
SET foo 123
GET foo
=> 123
SET bar 555
state
%{count: [%{"123" => 1, "555" => 1}], kv: [%{"bar" => "555", "foo" => "123"}]}
```