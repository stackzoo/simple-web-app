package main

blacklist = [
# Example
# "jboss"
]

invalidcmds = ["ssh", "vim", "shutdown", "service", "ps", "free", "top", "kill", "mount"]

#deny[msg]{
#    true
#    msg := sprintf("%v", [input])
#}

deny[msg] {
  input[i].Cmd == "from"
  val := input[i].Value
  contains(val[0], blacklist[_])

  msg = sprintf("blacklisted repository found '%s'", val)
}

# DL3000
deny[msg] {
    input[i].Cmd == "workdir"
    val := input[i].Value
    not startswith(val[0], "/")
    not startswith(val[0], "$")
    msg := sprintf("[DL3000] WORKDIR '%v' must be an absolute path.", val)
}

#DL3001
deny[msg] {
    input[i].Cmd == "run"
    val := input[i].Value
    cmds := regex.split("[ &;]+", val[0])
    contains(invalidcmds[_], cmds[j])
    msg := sprintf("[DL3001] line %v: command '%v' does not make sense inside a container.", [i+1, cmds[j]])
}

# Auxiliary Var
users := [y | y := input[x].Value[0]; input[x].Cmd == "user"]

#DL3002
deny[msg] {
    users[count(users) - 1] == "root"
    msg := "[DL3002] Last user should not be root"
}

#DL3002
deny[msg] {
    users[count(users)-1] == "0"
    msg := "[DL3002] Last user should not be root"
}

#DL3002
deny[msg] {
    count(users) == 0
    msg := "[DL3002] User should be set explicitly. Add a USER directive."
}

#DL3004
deny[msg] {
    input[i].Cmd == "run"
    val := input[i].Value
    cmds := regex.split("[ &;]+", val[0])
    cmds[x] == "sudo"
    msg := sprintf("[DL3004] line %v: Do not use 'sudo' as it leads to unpredictable behavior. Use a tool like gosu to enforce root.", [i])
}

get_image_tag(val) = image_tag {
    image := regex.split(":", val[0])
    image_tag := image[1]
}

#DL3006
deny[msg] {
    input[i].Cmd == "from"
    val := input[i].Value
    not get_image_tag(val)
    msg := "[DL3006] Always tag the version of an image explicitly."
}

#DL3007
deny[msg] {
    input[i].Cmd == "from"
    val := input[i].Value
    get_image_tag(val) == "latest"
    msg := "[DL3007] Using latest is prone to errors if the image will ever update. Pin the version explicitly to a release tag."
}


# DL3011
deny[msg] {
    input[i].Cmd == "expose"
    val := input[i].Value
    to_number(val[j]) > 65535
    msg := sprintf("[DL3011] line %v: Invalid port %v. Valid UNIX ports range from 0 to 65535", [i, val[j]])
}

# DL3021
deny[msg]{
    input[i].Cmd == "copy"
    val := input[i].Value
    count(val) > 2
    not endswith(val[count(val)-1], "/")
    msg := "[DL3021] COPY with more than 2 arguments requires the last argument to end with /"
}

#DL3027
deny[msg] {
    input[i].Cmd == "run"
    val := input[i].Value
    cmds := regex.split("[ &;]+", val[0])
    cmds[_] == "apt"
    msg := sprintf("[DL3027] line %v: Do not use apt as it is meant to be a end-user tool, use apt-get or apt-cache instead", [i+1])
}