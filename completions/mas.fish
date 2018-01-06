function __fish_mas_get_cmd -a include_opts
  for c in (commandline -opc)
    if not string match -q -- '-*' $c
      echo $c
    else
      # early stop once we've seen a `-*` modifier
      # (unless we marked the `include_opts` flag)
      if [ $include_opts != 0 ]
        echo $c
      else
        return
      end
    end
  end
end

function __fish_mas_needs_command
  set cmd (__fish_mas_get_cmd)
  if not set -q cmd[2]
    return 0
  end
  return 1
end

function __fish_mas_using_command
  set prefix 0
  set include_opts 0
  getopts $argv | while read -l key option
    switch $key
      case _
        set cmd_to_match $cmd_to_match $option
      case prefix
        set prefix 1
      case include_opts
        set include_opts 1
    end
  end

  set cmd (__fish_mas_get_cmd $include_opts)

  if set -q cmd[2..-1]
    set cmd $cmd[2..-1]

    if [ $prefix != 0 ]
      if not set -q cmd[1..(count $cmd_to_match)]
        return 1
      end
      set cmd $cmd[1..(count $cmd_to_match)]
    end

    if [ "$cmd_to_match" = "$cmd" ]
      return 0
    end
  end
  return 1
end

function __fish_mas_needs_command
    set cmd (commandline -opc)
    if [ (count $cmd) -eq 1 ]
        return 0
    else
        return 1
    end
end

function __fish_mas_installed_list
  mas list | perl -pe 's/ /\\t/'
end

function __fish_mas_outdated_list
  mas outdated | perl -pe 's/ /\\t/'
end

function __fish_mas_subcommands_suggest
  printf "account\tPrints the primary account Apple ID\n"
  printf "help\tDisplay general or command-specific help\n"
  printf "install\tInstall from the Mac App Store\n"
  printf "list\tLists apps from the Mac App Store which are currently installed\n"
  printf "outdated\tLists pending updates from the Mac App Store\n"
  printf "reset\tResets the Mac App Store\n"
  printf "search\tSearch for apps from the Mac App Store\n"
  printf "signin\tSign in to the Mac App Store\n"
  printf "signout\tSign out of the Mac App Store\n"
  printf "upgrade\tUpgrade outdated apps from the Mac App Store\n"
  printf "version\tPrint version number"
end

############
# commands #
############

for line in (__fish_mas_subcommands_suggest)
  set line (string split \t $line)
  set cmd $line[1]
  set desc $line[2]
  complete -xc mas -n '__fish_mas_needs_command' -a $cmd -d "$desc"
  complete -xc mas -n '__fish_mas_using_command help' -a $cmd -d "$desc"
end

# if it were possible to get `mas search` to provide all options in the same way as `brew search`
# then would do somehting like the following. For now, thiese completionsa re not provided.
# complete -f -c mas -n '__fish_mas_using_command install' -a "(__function_that_lists_all_instllable_apps)"
complete -f -c mas -n '__fish_mas_using_command install' -l force -d 'Force reinstall'
complete -f -c mas -n '__fish_mas_using_command reset' -l debug -d 'Enable debug mode'
complete -f -c mas -n '__fish_mas_using_command signin' -l dialog -d 'Complete login with graphical dialog'
complete -xc mas -n '__fish_mas_using_command upgrade --prefix' -a '(__fish_mas_outdated_list)'
# if there were an uninstall command, would do this
# complete -xc mas -n '__fish_mas_using_command uninstall --prefix' -a '(__fish_mas_installed_list)'
