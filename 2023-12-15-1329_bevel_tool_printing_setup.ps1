#!pwsh
. { #initialize 
    import-module neil-utility1
    Start-ScriptingJournalTranscript
    Set-Location $psscriptroot
    $bitwardenItemIdOfAutoscanMakerbot = "ef22ca4d-1b7f-4300-b7cd-b0da016636e2"

    # make sure we are using Windows' built-in build of OpenSSH rather than
    # (for example) cygwin's.
    ## $env:path = @(
    ##     (join-path $env:windir "System32" "OpenSSH")
    ##     $env:PATH -split [System.IO.Path]::PathSeparator
    ## ) -join [System.IO.Path]::PathSeparator

    #%%
    .{ # define the rr function for the makerbot
        $bitwardenItemId = $bitwardenItemIdOfAutoscanMakerbot
        $sshAgentEnvironment = initializeSshAgentFromBitwardenItemAndReturnSshAgentEnvironment $bitwardenItemId
        $sshOptionArguments = @( 

            # these options prevent us from touching our
            # main known_hosts file:
            "-o";"StrictHostKeyChecking=no"
            "-o";"UserKnownHostsFile=$(New-TemporaryFile)"
            "-o";"IdentityAgent=$($sshAgentEnvironment['SSH_AUTH_SOCK'])"
            getSshOptionArgumentsFromBitwardenItem -bitwardenItemId $bitwardenItemId
        )

       
        function rr { $input | runInSshSession -sshAgentEnvironment $sshAgentEnvironment -sshOptionArguments $sshOptionArguments @args }
        rr 'echo  "hello from $(hostname) at $(date)"'
    }
    #%%

}; return

{ # project setup:
    # see [https://github.com/neiljackson1984/makerbot_printable_maker] as a
    # reminder of how to user makerbot_printable_maker, see
    # [https://github.com/neiljackson1984/2022-11-27_caster_bushing] and
    # [https://github.com/neiljackson1984/2020-08-06_honda_fob_printing.git]


    gci -Directory U:\ -filter "*fob*"
    explorer "`"/root,U:\2020-08-06_honda_fob_printing`""

    push-location (New-TemporaryDirectory); git clone "https://github.com/neiljackson1984/makerbot_printable_maker"; push-location *; explorer "`"/root,$(resolve-path ".")`""; code ./make_printable.py
    push-location (New-TemporaryDirectory); git clone "https://github.com/neiljackson1984/2020-08-06_honda_fob_printing.git"; push-location *; explorer "`"/root,$(resolve-path ".")`"" ; code ./braids/makerbot_printable_maker/make_printable.py
    push-location (New-TemporaryDirectory); git clone "https://github.com/neiljackson1984/2022-11-27_caster_bushing"; push-location *; explorer "`"/root,$(resolve-path ".")`""; code ./braids/makerbot_printable_maker/make_printable.py



    push-location (New-TemporaryDirectory); git clone "https://github.com/neiljackson1984/2020-08-06_honda_fob_printing.git"; push-location *; 
    git status
    gi braids/makerbot_printable_maker
    braid --help
    braid setup --help
    braid push --help
    braid setup 
    braid push "./braids/makerbot_printable_maker"
    gc .braids.json
    git remote -v
    braid update --help
    gci
    braid push "$(resolve-path "braids/makerbot_printable_maker")" --verbose
    gi C:/Users/Admin/AppData/Local/Temp/braid_push* | remove-item -force -recurse
    bash
    braid push --verbose "braids/makerbot_printable_maker"
    git read-tree --help

    push-location "C:/Users/Admin/AppData/Local/Temp/braid_push.26920"
    git read-tree --prefix=/ -u e1baa9926886c50bd23727bc457492b02faa469c

    gem --help
    gem --version
    gem list --local braid
    gem list braid
    braid version
    ###     braid 1.1.2
    gem help commands
    gem search braid

    gem update --system

    choco search --exact ruby
    choco search  ruby
    get-command ruby
    get-command gem
    taskkill
    taskkill /f /im explorer.exe
    remove-item -force -recurse "C:\Ruby23-x64"
    handle "C:\Ruby23-x64"
    handle "C:\Ruby23-x64\bin\zlib1.dll"
    winget list ruby
    explorer
    choco upgrade --yes --acceptlicense --exact ruby
    choco uninstall --yes ruby
    gem install braid
    get-command braid
    braid version
    ###     braid 1.1.9

    gem
    gem server


    push-location (New-TemporaryDirectory); git clone "https://github.com/neiljackson1984/2020-08-06_honda_fob_printing.git"; push-location *; 
    braid push  "braids/makerbot_printable_maker"
    explorer "`"/root,$(resolve-path ".")`""
    gc .braids.json
    braid update
    git push


    cd u:\
    Remove-Item -Force -recurse "2023-12-15_bevel_tool_printing"
    cd (New-Item -ItemType Directory "2023-12-15_bevel_tool_printing" -force)
    git init

    git add .
    git commit -am "initial commit"
    braid add "https://github.com/neiljackson1984/makerbot_printable_maker" braids/makerbot_printable_maker
    explorer "`"/root,$(resolve-path ".")`""

    code braids\makerbot_printable_maker

}

{   # major thrash dealing with ssh-add not accepting my private key
    # and throwing an error complaining about invalid format.  
    # The problem ended up being due to newline format and powershell (on
    # several levels).

    get-command *ssh*

    initializeSshAgentFromBitwardenItem $bitwardenItemIdOfAutoscanMakerbot
    # oops.  initializeSshAgentFromBitwardenItem expects the bitwarden item to
    # contain an attached file named "id_rsa" containing the private key.  The
    # existing bitwarden item has an attached file named "c.openssh-private-key" containing the
    # private key putty format.

    # let's download c.openssh-private-key and then re-upload it as a new attached file named "id_rsa".
    # (I did this with the bitwarden gui)

    bw sync

    initializeSshAgentFromBitwardenItem $bitwardenItemIdOfAutoscanMakerbot

    # oops.  the key is not in the right format.  I want a key whose first line is
    # "-----BEGIN RSA PRIVATE KEY-----" (a.k.a. PEM format), but the aforementioned
    # file c.openssh-private-key has a first line that is "-----BEGIN OPENSSH
    # PRIVATE KEY-----" (RFC4716 format)

    # it looks the version of openssh (and ssh-add, and ssh-agent, etc.) that I'm using,
    # which is from cygwin is too old to support the (newer, better "BEGIN OPENSSH
    # PRIVATE KEY" format).

    get-command ssh
    ssh --help
    ssh -V
    ssh --version


    get-command ssh-add -all
    ssh-add --help
    ssh-add -v

    getSshPrivateKeyFromBitwardenItem $bitwardenItemIdOfAutoscanMakerbot | ssh-add -vvv -

    dir env:

    # "ssh-add" "Error loading key" "invalid format" "BEGIN OPENSSH PRIVATE KEY"
    # "BEGIN RSA PRIVATE KEY" vs. "BEGIN OPENSSH PRIVATE KEY"
    # see [https://superuser.com/questions/1720991/differences-between-begin-rsa-private-key-and-begin-openssh-private-key
    # see [https://stackoverflow.com/questions/56473553/why-cant-openssl-read-an-ssh-private-key-created-by-openssh-on-osx]
    # see [https://stackoverflow.com/questions/54994641/openssh-private-key-to-rsa-private-key]

    # see [https://www.openssh.com/manual.html]

    get-command -all ssh | select @(
        "Path"
        {& "$($_.Path)" "-V" 2>&1}
    )
    <#
        Path                                & "$($_.Path)" "-V" 2>&1
        ----                                ------------------------
        C:\cygwin64\bin\ssh.exe             OpenSSH_9.4p1, OpenSSL 1.1.1w  11 Sep 2023
        C:\WINDOWS\System32\OpenSSH\ssh.exe OpenSSH_for_Windows_8.6p1, LibreSSL 3.4.3
    #>

    $openSshPrivateKey = getSshPrivateKeyFromBitwardenItem $bitwardenItemIdOfAutoscanMakerbot 
    $openSshPrivateKey | ssh-add -vvv -

    # which is better? rsa vs. openssh key format

    # it sounds like the OpenSSH key format is newer and possibly technically
    # superior, but ssh-add does not support it (even in the newest version of
    # openssh)  I don't understand.

    # perhaps there is merely something pathological about this particular key that I  am using.
    #
    # Let's test to confirm that our currently-installed version of ssh-add  (version 9.4p1) supports the "BEGIN OPENSSH PRIVATE KEY" format.
    #
    # actually, let's see if ssh-keygen can convert our "BEGIN OPENSSH PRIVATE KEY" formatted key into a PEM-formatted key, and then
    # see if we can give the resultant PEM-foramtted key to ssh-add without error.

    # see [https://man.openbsd.org/ssh-keygen]

    $pathOfOpenSshPrivateKeyFile = "openssh_private_key"
    $pathOfPemPrivateKeyFile = "pem_private_key"
    Set-content $pathOfOpenSshPrivateKeyFile -Value $openSshPrivateKey
    Copy-Item -force $pathOfOpenSshPrivateKeyFile $pathOfPemPrivateKeyFile
    gc $pathOfOpenSshPrivateKeyFile
    gc $pathOfPemPrivateKeyFile

    # ssh-keygen is geared toward doing an in-place conversion of the file, which is a bit weird but oh well.
    ssh-keygen -p -P "" -m PEM -f $pathOfPemPrivateKeyFile
    # Failed to load key pem_private_key: invalid format

    ssh-keygen -P "" -e -f $pathOfOpenSshPrivateKeyFile

    # new experiment: generate a "BEGIN OPENSSH PRIVATE KEY" de novo, and see if we run into the same problem with it.
    Remove-Item -force $pathOfOpenSshPrivateKeyFile, $pathOfPemPrivateKeyFile

    ## ssh-keygen -t rsa -m PEM -N "" -f $pathOfOpenSshPrivateKeyFile
    # this created a private key file whose first line is "-----BEGIN RSA PRIVATE KEY-----"

    ssh-keygen -t rsa -N "" -f $pathOfOpenSshPrivateKeyFile
    # now, the first line of the file at $pathOfOpenSshPrivateKeyFile is "-----BEGIN OPENSSH PRIVATE KEY-----", as desired.

    ssh-keygen -P "" -e -f $pathOfOpenSshPrivateKeyFile
    # no error - spits out the public key

    Copy-Item -force $pathOfOpenSshPrivateKeyFile $pathOfPemPrivateKeyFile
    ssh-keygen -p -P "" -N "" -m PEM -f $pathOfPemPrivateKeyFile
    # no error.  The first line of the file $pathOfPemPrivateKeyFile is "-----BEGIN
    # RSA PRIVATE KEY-----", as expected.

    # all of this makes me think there is something pathoilogical about my c.openssh-private-key file.
    # could it be as stupid as line endings?

    notepad++ $pathOfOpenSshPrivateKeyFile

    # no, its' probably not line endings.

    # let's get the ppk file from the bitwarden item and use puttygen to generate a
    # new private key file in either PEM or "BEGIN OPENSSH PRIVATE KEY" formats.

    $bitwardenItemIdOfSshKeyForAutoscanMakerbot = (getFieldMapFromBitwardenItem $bitwardenItemIdOfAutoscanMakerbot)['ssh_private_key_reference']

    $ppkPrivateKey = bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot

    $x = Get-BitwardenItem $bitwardenItemIdOfSshKeyForAutoscanMakerbot
    $x.attachments | select filename

    $ppkPrivateKey = bw --raw get attachment "c.ppk" --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot
    get-command puttygen

    puttygen --help
    $pathOfPpkFile = "ppk_private_key"
    $pathOfTestPrivateKeyFile = "test_private_key"
    Set-content $pathOfPpkFile -Value $ppkPrivateKey
    ## puttygen $pathOfPpkFile -O private-openssh -o $pathOfTestPrivateKeyFile
    # oops no real command-line support by puttygen.  I'll just use the gui
    puttygen $pathOfPpkFile 
    # In the puttygen gui, I want to Conversions, and then ran "Export OpenSSH key",
    # "Export OpenSSH key (Force new file format)", and  "Export ssh.com key". I
    # saved the output to the files key1, key2, and key3, respectively.

    gc key1 
    # starts with "-----BEGIN RSA PRIVATE KEY-----"

    gc key2
    # starts with "-----BEGIN OPENSSH PRIVATE KEY-----" the file is different from
    # the c.openssh-private-key file attached to the bitwarden item.

    gc key3
    # starts with "---- BEGIN SSH2 ENCRYPTED PRIVATE KEY ----".

    # can openssh handle key2?

    ssh-keygen -P "" -e -f key2
    # no error. so, yes, it can.  

    ssh-keygen -P "" -e -f key4

    (gc -raw key4) -ceq (gc -raw key2)
    (gc -raw key2).GetTYpe().FullName
    notepad++ key4
    notepad++ key2

    gc key4


    # the hypothesis of pathology unique to the c.openssh-private-key file seems to
    # make sense. we will oiverwrite c.openssh-private-key with key4, and will
    # create an attachment named "id_rsa" with the
    # contents of key4.

    bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot
    bw edit --help
    bw create --help

    Copy-Item -force key2 c.openssh-private-key
    Copy-Item -force key2 id_rsa
    bw create --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot --file c.openssh-private-key attachment

    ## oops., that just added a new c.openssh-private-key without deleting the existing one.

    bw delete --help

    (Get-BitwardenItem $bitwardenItemIdOfSshKeyForAutoscanMakerbot).attachments

    #%%
    (Get-BitwardenItem $bitwardenItemIdOfSshKeyForAutoscanMakerbot).attachments |? {$_.fileName -in "id_rsa","c.openssh-private-key"} |
    %{
        bw delete --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot attachment $_.id
    }
    @("c.openssh-private-key"; "id_rsa") | %{ bw create --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot --file $_ attachment}
    #%%

    Copy-Item -force key2 c.openssh-private-key
    Copy-Item -force key2 id_rsa
    ssh-keygen -P "" -e -f key2
    ssh-keygen -P "" -e -f id_rsa
    ssh-keygen -P "" -e -f c.openssh-private-key

    #%%
    (Get-BitwardenItem $bitwardenItemIdOfSshKeyForAutoscanMakerbot).attachments |? {$_.fileName -in "id_rsa","c.openssh-private-key"} |
    %{
        bw delete --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot attachment $_.id
    }
    @("c.openssh-private-key"; "id_rsa") | %{ bw create --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot --file $_ attachment}
    #%%



    initializeSshAgentFromBitwardenItem $bitwardenItemIdOfAutoscanMakerbot

    gc key2
    gc $pathOfOpenSshPrivateKeyFile

    (gc -raw $pathOfOpenSshPrivateKeyFile) -ceq (gc -raw key2)

    (gc -raw key2) -ceq (bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot | out-string )

    Set-Content xxx -Value (bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot)
    gc -raw xxx
    notepad++ xxx
    notepad++ key2
    notepad++ $pathOfOpenSshPrivateKeyFile
    (bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot | out-string ).Count
    $(bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot).Count

    ssh-keygen -P "" -e -f key2
    ssh-keygen -P "" -e -f $pathOfOpenSshPrivateKeyFile

    ##### IT IS the LINE ENDINGS.  GOD DAMNIT!
    # see
    # [https://stackoverflow.com/questions/48371447/piping-text-to-an-external-program-appends-a-trailing-newline/48372333#48372333]
    # the problem happens when I invoke bw --raw get attachment id_rsa ... .  Even
    # though that command is outputting the exact bytes in the file ,. powershell is
    # chopping into strings at the line breaks, and then, adding windows-style
    # linefeeds when piped to ssh-add.

    bw get --help
    gc -raw key2 | ssh-keygen -P "" -e -f -

    (gc -raw key2 ).Count

    bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot | ssh-add -
    gc -raw key2 | ssh-add -
    gc key2 | ssh-add -
    Set-content yyy (gc key2 )
    notepad++ yyy
    ssh-add yyy
    gc yyy | ssh-add -

    # see [https://stackoverflow.com/questions/59110563/different-behaviour-and-output-when-piping-in-cmd-and-powershell/59118502#59118502]
    bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot > aa
    bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot --output zzz
    bash -c "bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot > zzz"
    bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot | bash -c "cat > zzz"
    bash -c "cat key2" | bash -c "cat > zzz"
    powershell -c {bash -c "cat key2" | bash -c "cat > zzz"}
    pwsh -c {bash -c "cat key2" | bash -c "cat > zzz"}
    $(bash -c "cat key2") | bash -c "cat > zzz"
    bash -c "cat key2" | bash -c "cat > zzz"
    notepad++ zzz
    notepad++ aa

    choco search pwsh
    choco search --prerelease pwsh
    choco search --prerelease powershell
    choco search --help

    choco upgrade --yes --acceptlicense powershell-preview
    choco uninstall powershell-preview

    get-command -all pwsh
    get-command bw | select *

    # The PSNativeCommandPreserveBytePipe feature is great, but doesn't help us when
    # we do 
    # ```
    # bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot > aa
    # ```
    # because bw is not a native executable, but is rather a powershell script. bizarre.

    # I think this might have happened when I installed the npm  bitwarden module
    # rather than the native executable bitwarden .  That npm module does include a
    # powershell script.
    #
    # It is very confusing that a command implemented via powershell script should
    # behave differently from a native command when output is piped to a file (I
    # understand why it is happenning, but it is still generally confusing and
    # annoying).  I  shouldn't have to care about whether my bw command is
    # implemented in a powershell script (that calls node) or an executable (that
    # was compiled from node javascript). This business about piping byte streams
    # around is really a major annoyance when it comes to the newline problem. I am
    # not sure what the best answer is.  


    get-command -all bw
    get-command -all bw.exe
    npm 
    npm ls
    npm view bw
    npm ls -g -depth 0
    npm uninstall bitwarden/cli
    npm uninstall -g @bitwarden/cli

    get-command -all npm

    choco list bw
    choco search bw
    choco search bitwarden
    choco list bitwarden
    choco uninstall bitwarden
    choco upgrade --acceptlicense --yes bitwarden-cli

    get-command -all bw
    $x = bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot
    $x.Count
    $x | ssh-add -
    [System.Text.UTF8Encoding]::new().GetBytes($x[0])

    bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot | ssh-add -
    getSshPrivateKeyFromBitwardenItem $bitwardenItemIdOfSshKeyForAutoscanMakerbot | ssh-add -

    $bitwardenItemIdOfItemContainingTheKeyAsAnAttachedFile = $bitwardenItemIdOfSshKeyForAutoscanMakerbot
    $process = New-Object "System.Diagnostics.Process" -Property @{
        StartInfo = (
            @{
                TypeName = "System.Diagnostics.ProcessStartInfo"
                ArgumentList = @(
                    (Get-Command bw).Path
                    ,@(
                        "--raw" 
                        "get"; "attachment"; "id_rsa"
                        "--itemid"; $bitwardenItemIdOfItemContainingTheKeyAsAnAttachedFile
                    )
                )
                Property = @{
                    RedirectStandardOutput = $True
                }
            } | % { New-Object @_} 
        )
    }

    $process.Start()
    $process.WaitForExit()
    $sshPrivateKey = $process.StandardOutput.ReadToEnd()

    $sshPrivateKey.Count

    [System.Text.UTF8Encoding]::new().GetBytes($sshPrivateKey)

    $sshPrivateKey  | ssh-add -
    [System.Text.UTF8Encoding]::new().GetBytes($sshPrivateKey) | ssh-add -


    bw --raw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot 
    bw get attachment id_rsa --itemid $bitwardenItemIdOfSshKeyForAutoscanMakerbot 
    remove-item id_rsa

}

{ # futz with scp arguments for uploading the file

    rr ls
    rr env
    rr hostname
    rr 'ls /home/usb_storage/'
    rr 'ls -al /home/usb_storage/'
    rr 'cat /home/usb_storage/.dropbox.device'
    rr 'ls -al "/home/usb_storage/System Volume Information"'
    rr 'cat "/home/usb_storage/System Volume Information/IndexerVolumeGuid"'
    rr 'cat "/home/usb_storage/System Volume Information/WPSettings.dat"'
    rr 'rm -rf "/home/usb_storage/System Volume Information"'
    rr 'rm -f "/home/usb_storage/.dropbox.device"'
    rr 'ls /home/usb_storage/archive'
    rr 'mv /home/usb_storage/20221127_153801--honda_fob.makerbot "/home/usb_storage/archive"'
    rr 'mv /home/usb_storage/*.* "/home/usb_storage/archive"'
    rr 'mkdir "/home/usb_storage/main"'
    rr 'ls -al "/home/usb_storage/main"'
    rr 'ls -al "/home/usb_storage/main"'
    rr 'rm -f "/home/usb_storage/main/"*'
    rr 'rm -rf "/home/usb_storage/main"'


    get-command scp -all

    scp --help
    # see [https://man.openbsd.org/scp]

    $d = New-TemporaryDirectory
    $f = (join-path $d "test.txt") 
    Set-Content $f -Value "ahoy this is just a asdfasdfadsf test"
    gc $f
    scp @sshOptionArguments $f "dummy:/home/usb_storage/main"
    scp @sshOptionArguments "$f" "dummy:/home/usb_storage/main/test.txt"
    scp @sshOptionArguments "'$f'" "dummy:/home/usb_storage/main/test.txt"
    scp @sshOptionArguments $(cygpath $f) "dummy:/home/usb_storage/main/test.txt"
    scp @sshOptionArguments $(cygpath $f) "scp://makerbot.ad.autoscaninc.com//home/usb_storage/main/test.txt"
    scp @sshOptionArguments $(cygpath $f) "scp://dummy//home/usb_storage/main/test.txt"
    scp @sshOptionArguments $(cygpath $f) "scp://dummy//home/usb_storage/main/test1.txt"
    scp @sshOptionArguments "':$f'" "dummy:/home/usb_storage/main/test.txt"
    scp @sshOptionArguments "'/$f'" "dummy:/home/usb_storage/main/test.txt"
    scp @sshOptionArguments "`"/$f`"" "dummy:/home/usb_storage/main/test.txt"
    scp @sshOptionArguments "/$f" "dummy:/home/usb_storage/main/test.txt"
    scp @sshOptionArguments "$f" "dummy:/home/usb_storage/main/test.txt"
    scp @sshOptionArguments "\\$f" "dummy:/home/usb_storage/main/test.txt"
    scp @sshOptionArguments "///$f" "dummy:/home/usb_storage/main/test.txt"
    scp @sshOptionArguments ":$f" "dummy:/home/usb_storage/main/test.txt"


    Get-command -all scp
    Get-command -all ssh-add
    scp @sshOptionArguments "/`"$f`"" "dummy:/home/usb_storage/main/test.txt"
    & "C:\WINDOWS\System32\OpenSSH\scp.exe" @sshOptionArguments "/`"$f`"" "dummy:/home/usb_storage/main/test.txt"
    & "C:\WINDOWS\System32\OpenSSH\ssh-add.exe"

    scp @sshOptionArguments "/$f" "dummy:/home/usb_storage/main/test.txt"
    scp @sshOptionArguments "./$f" "dummy:/home/usb_storage/main/test.txt"
    scp @sshOptionArguments "/$(cygpath --mixed $f)" "dummy:/home/usb_storage/main/test.txt"
    scp @sshOptionArguments "//$(cygpath --mixed $f)" "dummy:/home/usb_storage/main/test.txt"

    scp @sshOptionArguments "localhost:$(cygpath --mixed $f)" "dummy:/home/usb_storage/main/test.txt"
    (resolve-path $f).GetType()
    get-command bash
    bash -c "cat '$f'"
    cygpath --mixed $f

    cygpath
    rr cat /home/usb_storage/main/test.txt

    initializeSshAgentFromBitwardenItemAndReturnSshAgentEnvironment $bitwardenItemId

    ssh-agent -s -D


    (Get-Location).GetType().FullName
    ### System.Management.Automation.PathInfo
    (Get-Location).Path.GetType().FullName
    (Get-Location) | select *
    "$(Get-Location)"

    $f.GetType().FullName
    [System.IO.Path]::GetRelativePath( "$(Get-Location)", $f )
    # thqat doesn't always work, because we could be on a different drive than $f.
    push-location (split-path -parent $f)
    (join-path "." ([System.IO.Path]::GetRelativePath( "$(Get-Location)", $f )))
    cd ..
    pop-location

    Get-Service ssh-agent


    # see [https://stackoverflow.com/questions/52113738/starting-ssh-agent-on-windows-10-fails-unable-to-start-ssh-agent-service-erro]
    # see [https://rabexc.org/posts/pitfalls-of-ssh-agents]

    <#  I am running into a problem with passing the path of a file on the local
        Windows filesystem to (the cygwin version of) scp as the "source" argument.
        The problem is that he Windows path contains a colon, which scp interprets
        as a separator between the host name and the path of the file on that host,
        rather than merely as part of the opaque path of a file.  The workarounds
        are either to pass the path through cygpath (this would only work with the
        cygwin version of scp) or to try to use the built-in Windows version of scp
        (although I don't know how the built-in windows version of scp is deals with
        the colon problem.)

        The [scp documentation] (https://man.openbsd.org/scp) mentions that "Local
        file names can be made explicit using absolute or relative pathnames to
        avoid scp treating file names containing ‘:’ as host specifiers."  This
        sounds promising, but the best I can think to do is to stick a forward slash
        in front of the Windows-style path.  This does cause scp to assume that the
        "source" path is a path to a file in the local file system, but it still
        cannot find the file, complaining 
        ```
        /usr/bin/scp: stat local "/C:\\Users\\Admin\\AppData\\Local\\Temp\\c063fc5a-0bc9-40cd-addc-86164a1c0162\\test.txt": No such file or directory
        ```



    #>

    # scp @sshOptionArguments "$(cygpath $f)" "dummy:/home/usb_storage/main/test.txt"

    # thisn is clunky, but it will work:
    push-location (split-path -parent $f)
    scp @sshOptionArguments "$(join-path "." ([System.IO.Path]::GetRelativePath( "$(Get-Location)", $f )))"  "dummy:/home/usb_storage/main/test.txt"
    pop-location

    push-location (split-path -parent $f)
    gc "$(join-path "." ([System.IO.Path]::GetRelativePath( "$(Get-Location)", $f )))"
    # sftp  @sshOptionArguments dummy
    ssh @sshOptionArguments dummy 'mkdir -p /home/usb_storage/main'
    ssh @sshOptionArguments dummy 'ls -al /home/usb_storage/main'
    scp -v -r @sshOptionArguments "$(join-path "." ([System.IO.Path]::GetRelativePath( "$(Get-Location)", $f )))"  "dummy:/home/usb_storage/main/a/test.txt"
    pop-location

}

get-command pscp -all


gi "C:\Program Files\MakerBot\MakerBotPrint\resources\app.asar.unpacked\node_modules\MB-support-plugin\mb_ir\MakerWare"

scp  @sshOptionArguments "$(join-path "." ([System.IO.Path]::GetRelativePath( "$(Get-Location)", (resolve-path "./build/3in_hdpe_bevel.makerbot") )))"  "dummy:/home/usb_storage/3in_hdpe_bevel_$(get-date -format "yyyyMMdd_HHmmss").makerbot"

initializeSshAgentFromBitwardenItem $bitwardenItemIdOfAutoscanMakerbot
make

choco search makerbot

push-location (New-TemporaryDirectory); git clone "https://github.com/neiljackson1984/makerbot_uart"; push-location *; explorer "`"/root,$(resolve-path ".")`""; code .

# set the date on the makerbot
rr "ntpd -d -n -q -g -p pool.ntp.org"
push-location braids/makerbot_printable_maker
pipenv --venv
gci $(pipenv --venv)
pipenv --rm
pipenv install
pop-location

git remote add origin https://github.com/neiljackson1984/2023-12-15_bevel_tool_printing.git
git push -u origin master

npm --help

npm help update

npm -l

npm search MB-support-plugin
npm search makerbot

push-location (New-TemporaryDirectory); git clone "https://github.com/neiljackson1984/2020-08-06_honda_fob_printing.git"; push-location *; explorer "`"/root,$(resolve-path ".")`"" ; 

choco search cura

winget list cura
winget  cura
choco search --exact --verbose cura
choco search --exact --verbose cura-new 

winget upgrade cura
winget uninstall cura
winget --help
winget upgrade --help 

choco install --accept-license --yes cura-new
get-command cura -all
findfileinprogramfiles *cura*.exe

choco list --verbose cura-new
get-command "UltiMaker-Cura"
& "C:\Program Files\UltiMaker Cura 5.5.0\UltiMaker-Cura.exe"