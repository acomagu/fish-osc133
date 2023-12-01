# Based on https://gitlab.freedesktop.org/Per_Bothner/specifications/-/blob/master/proposals/prompts-data/shell-integration.fish

if not status --is-interactive
    return
end

set -g _fishprompt_aid "fish"$fish_pid
set -g _fishprompt_started 0
# empty if running; or a numeric exit code; or CANCEL
set -g _fishprompt_postexec ""

set _fishprompt_prompt_count 0
set _fishprompt_disp_count 0

function _fishprompt_preexec --on-event fish_preexec
    if [ "$_fishprompt_started" = 1 ]
        printf "\033]133;C;\007"
    end
    set _fishprompt_started 0
end

function _fishprompt_postexec --on-event fish_postexec
    set _fishprompt_postexec $status
end

function __fishprompt_cancel --on-event fish_cancel
    set _fishprompt_postexec CANCEL
    _fishprompt_start
end

function _fishprompt_exit --on-process %self
    if [ "$_fishprompt_started" = 1 ]
        printf "\033]133;Z;aid=%s\007" $_fishprompt_aid
    end
end

function _fishprompt_start --on-event fish_prompt
    set _fishprompt_prompt_count (math $_fishprompt_prompt_count + 1)
    # don't use post-exec, because it is called *before* omitted-newline output
    if [ -n "$_fishprompt_postexec" ]
        printf "\033]133;D;%s;aid=%s\007" "$_fishprompt_postexec" $_fishprompt_aid
    end
    printf "\033]133;A;aid=%s;cl=m\007" $_fishprompt_aid
end

function _osc133_setup --on-event fish_prompt
    functions -e (status current-function)

    functions -c fish_prompt _fishprompt_saved_prompt

    function fish_prompt
        set _fishprompt_disp_count (math $_fishprompt_disp_count + 1)
        printf "\033]133;P;k=i\007%b\033]133;B\007" (string join "\n" (_fishprompt_saved_prompt))
        set _fishprompt_started 1
        set _fishprompt_postexec ""
    end
end
