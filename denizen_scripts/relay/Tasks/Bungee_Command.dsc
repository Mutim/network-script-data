Bungee_DCommand:
    type: task
    PermissionRoles:
# - ██ [ Staff Roles  ] ██
        - Development Team
        - Lead Developer
        - Bungeeternal Developer
        - Developer

# - ██ [ Public Roles ] ██
        - Development Team
        - Lead Developer
        - Developer
    definitions: Message|Channel|Author|Group
    debug: false
    ContBungeet: Color
    speed: 0
    script:
# - ██ [ Clean Definitions & Inject Dependencies ] ██
        - define Message <[Message].unescaped>
        - inject Role_Verification
        - inject Command_Arg_Registry
        
# - ██ [ Verify Arguments                        ] ██
        - if <[Args].is_empty>:
            - stop
        - define server <[Args].first>
        - if !<bungee.list_servers.contains[<[Server]>]>:
            - define Reason "Invalid Server"
            - discord id:aurorabot message channel:<[Channel]> <[Reason]>
            - stop
            
        - run discord_bungeeCommand_execute def:<[Message].after[<&sp>].before[<&sp>]>|<[Message].after[<&sp>].after[<&sp>].replace[<&sp>].with[<&ns>]>|<[Channel]>

#^ /bungee behr ```yml
#^ - define World <world[World]>
#^ - announce "Hello <[World].name>!"```

# - ██ [ Send Embedded Message                   ] ██
        #- run Embedded_Discord_Message def:Command_Ran|<[Channel]>|<list[Color/Code|Author/<[Author].Name>|Server/<[Server].to_titlecase>|Command//<[Command].escaped>].escaped>


# ^ /bungee announce Hello everyone!;announce We'll be starting in an hour.;announce Thanks.
discord_bungeeCommand_execute:
  type: task
  debug: false
  definitions: server|element|channel
  script:
    - foreach <[element].split[;]>:
      - define line<[loop_index]> <[value].replace[<&ns>].with[<&sp>]>
    - define command <element[]>
    - repeat 9999:
      - if <[line<[value]>]||invalid> == invalid:
        - repeat stop
      - define command "<[command]>- <[line<[value]>]><&nl>"
    - if <[Server]> == all:
      - foreach <bungee.list_servers.exclude[<bungee.server>]> as:Server:
        - execute as_server "ex bungee <[server]> { <[command]> }"
        - define ServersRan:->:<[Server]>
      - discord id:AuroraBot message channel:<[channel]> "Executed Commands on <[ServersRan].comma_separated>:<&nl>```ini<&nl><[Command].split[<&nl>].separated_by[<&nl>]>```"
    - else if !<bungee.list_servers.contains[<[Server]>]>:
      - discord id:AuroraBot message channel:<[channel]> "<&lt>a:weewoo:619323397880676363<&gt> **Invalid Server**: `<[server]>` <&lt>a:weewoob:724672346807599282<&gt>"
      - stop
    - else:
      - execute as_server "ex bungee <[server]> { <[command]> }"
    #^- discord id:AuroraBot message channel:<[channel]> "Executed Commands on <[server]>:<&nl>```ini<&nl><[Command].split[<&nl>].separated_by[<&nl>]>```"

      
    - define color Code
    - inject Embedded_Color_Formatting
    - define Text "Executed Commands on <[server]>:<&nl>```ini<&nl><[Command].split[<&nl>].separated_by[<&nl>]>```"
    - define Embeds "<list[<map[color/<[Color]>].with[description].as[<[Text]>]>]>"
    - define Data <map[username/<[Server]><&sp>Server|avatar_url/https://img.icons8.com/nolan/64/buysellads.png].with[embeds].as[<[Embeds]>].to_json>

    - define Hook <script[DDTBCTY].data_key[WebHooks.<[Channel]>.hook]>
    - define headers <list[User-Agent/really|Content-Type/application/json]>
    - ~webget <[Hook]> data:<[Data]> headers:<[Headers]>
