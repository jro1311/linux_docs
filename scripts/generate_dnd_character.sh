#!/usr/bin/env bash
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc
shopt -u globstar nullglob

describe_racial_traits() {
    race="$1"

    case "$race" in
        "dragonborn")
            printf "Draconic Ancestry: Determines your breath weapon type and resistance.\n"
            printf "Breath Weapon: Exhale damaging energy once per rest.\n"
            printf "Damage Resistance: Resist the damage type of your ancestry.\n"
            ;;

        "elf")
            printf "Darkvision: See in dim light (60 ft) and darkness.\n"
            printf "Keen Senses: Proficiency in Perception.\n"
            printf "Fey Ancestry: Advantage vs charm; immune to magical sleep.\n"
            printf "Trance: Meditate 4 hours instead of sleeping.\n"
            ;;

        "gnome")
            printf "Darkvision: See in dim light (60 ft) and darkness.\n"
            printf "Gnome Cunning: Advantage on INT, WIS, CHA saves vs magic.\n"
            ;;

        "half-elf")
            printf "Darkvision: See in dim light (60 ft) and darkness.\n"
            printf "Fey Ancestry: Advantage vs charm; immune to magical sleep.\n"
            printf "Skill Versatility: Proficiency in two skills of your choice.\n"
            printf "Ability Bonus: +1 to two abilities of your choice.\n"
            ;;

        "half-orc")
            printf "Darkvision: See in dim light (60 ft) and darkness.\n"
            printf "Menacing: Proficiency in Intimidation.\n"
            printf "Relentless Endurance: Drop to 1 HP instead of 0 once per rest.\n"
            printf "Savage Attacks: Extra damage die on melee crits.\n"
            ;;

        "halfling")
            printf "Lucky: Reroll 1s on attacks, checks, and saves.\n"
            printf "Brave: Advantage on saves vs fear.\n"
            printf "Halfling Nimbleness: Move through spaces of larger creatures.\n"
            ;;

        "hill-dwarf")
            printf "Darkvision: See in dim light (60 ft) and darkness.\n"
            printf "Dwarven Resilience: Advantage vs poison; resistance to poison damage.\n"
            printf "Dwarven Combat Training: Proficiency with dwarf weapons.\n"
            printf "Tool Proficiency: Smith, brewer, or mason tools.\n"
            printf "Stonecunning: Double proficiency on stonework History checks.\n"
            printf "Dwarven Toughness: +1 HP per level.\n"
            ;;

        "human")
            printf "Extra Language: You speak one additional language.\n"
            ;;

        "mountain-dwarf")
            printf "Darkvision: See in dim light (60 ft) and darkness.\n"
            printf "Dwarven Resilience: Advantage vs poison; resistance to poison damage.\n"
            printf "Dwarven Combat Training: Proficiency with dwarf weapons.\n"
            printf "Tool Proficiency: Smith, brewer, or mason tools.\n"
            printf "Stonecunning: Double proficiency on stonework History checks.\n"
            printf "Dwarven Armor Training: Proficiency with light and medium armor.\n"
            ;;

        "tiefling")
            printf "Darkvision: See in dim light (60 ft) and darkness.\n"
            printf "Hellish Resistance: Resistance to fire damage.\n"
            printf "Infernal Legacy: Thaumaturgy cantrip; later Hellish Rebuke and Darkness.\n"
            ;;
    esac
}

roll_stat() {
    awk -v seed="$(date +%s%N)" '
        BEGIN {
            srand(seed)
            d1 = int(rand()*6)+1
            d2 = int(rand()*6)+1
            d3 = int(rand()*6)+1
            print d1 + d2 + d3 + 3
        }
    '
}

print_ability() {
    ability="$1"
    score="$2"
    mod="$3"

    if [ "$mod" -gt 0 ]; then
        mod_fmt="+$mod"
    else
        mod_fmt="$mod"
    fi

    green_message "$ability:" "$score  [$mod_fmt]"
}

str=0
dex=0
con=0
int=0
wis=0
cha=0

str_mod=0
dex_mod=0
con_mod=0
int_mod=0
wis_mod=0
cha_mod=0

hp=0
hit_die=0

race=""
race_uc=""
class=""

green_message "Races:"
echo "Dragonborn
Elf
Gnome
Half-Elf
Half-Orc
Halfling
Hill-Dwarf
Human
Mountain-Dwarf
Tiefling"
read -er -p "Enter race: " race

if [ -z "$race" ]; then
    red_message "Error:" "No race selected."
    exit 1
fi

race=$(printf '%s' "$race" | tr '[:upper:]' '[:lower:]')

case "$race" in
    "dragonborn")
        race_uc="Dragonborn"
        ;;
    "elf")
        race_uc="Elf"
        ;;
    "gnome")
        race_uc="Gnome"
        ;;
    "half-elf")
        race_uc="Half-Elf"
        ;;
    "half-orc")
        race_uc="Half-Orc"
        ;;
    "halfling")
        race_uc="Halfling"
        ;;
    "hill-dwarf")
        race_uc="Hill-Dwarf"
        ;;
    "human")
        race_uc="Human"
        ;;
    "mountain-dwarf")
        race_uc="Mountain-Dwarf"
        ;;
    "tiefling")
        race_uc="Tiefling"
        ;;
    *)
        red_message "Unknown race:" "$race"
        exit 1
esac

green_message "Classes:"
echo "Barbarian
Bard
Cleric
Druid
Fighter
Monk
Paladin
Ranger
Rogue
Sorcerer
Warlock
Wizard"
read -er -p "Enter class: " class

if [ -z "$class" ]; then
    red_message "Error:" "No class selected."
    exit 1
fi

class=$(printf '%s' "$class" | tr '[:upper:]' '[:lower:]')
class_uc=""

case "$class" in
    "barbarian")
        class_uc="Barbarian"
        hit_die=12
        primary_ability="STR"
        saves="STR, CON"
        ;;
    "bard")
        class_uc="Bard"
        hit_die=8
        primary_ability="CHA"
        saves="DEX, CHA"
        ;;
    "cleric")
        class_uc="Cleric"
        hit_die=8
        primary_ability="WIS"
        saves="WIS, CHA"
        ;;
    "druid")
        class_uc="Druid"
        hit_die=8
        primary_ability="WIS"
        saves="INT, WIS"
        ;;
    "fighter")
        class_uc="Fighter"
        hit_die=10
        primary_ability="STR or DEX"
        saves="STR, CON"
        ;;
    "monk")
        class_uc="Monk"
        hit_die=8
        primary_ability="DEX and WIS"
        saves="STR, DEX"
        ;;
    "paladin")
        class_uc="Paladin"
        hit_die=10
        primary_ability="STR and CHA"
        saves="WIS, CHA"
        ;;
    "ranger")
        class_uc="Ranger"
        hit_die=10
        primary_ability="DEX and WIS"
        saves="STR, DEX"
        ;;
    "rogue")
        class_uc="Rogue"
        hit_die=8
        primary_ability="DEX"
        saves="DEX, INT"
        ;;
    "sorcerer")
        class_uc="Sorcerer"
        hit_die=6
        primary_ability="CHA"
        saves="CON, CHA"
        ;;
    "warlock")
        class_uc="Warlock"
        hit_die=8
        primary_ability="CHA"
        saves="WIS, CHA"
        ;;
    "wizard")
        class_uc="Wizard"
        hit_die=6
        primary_ability="INT"
        saves="INT, WIS"
        ;;
    *)
        red_message "Unknown class:" "$class"
        exit 1
esac

green_message "Race:" "$race_uc"
green_message "Racial Traits:" && describe_racial_traits "$race"

green_message "Class:" "$class_uc"
green_message "Hit Die:" "d$hit_die"
green_message "Primary Ability:" "$primary_ability"
green_message "Saves:" "$saves"

for ability in str dex con int wis cha; do
    value=$(roll_stat)

    case "$ability" in
        "str") str="$value" ;;
        "dex") dex="$value" ;;
        "con") con="$value" ;;
        "int") int="$value" ;;
        "wis") wis="$value" ;;
        "cha") cha="$value" ;;
    esac
done

case "$race" in
    "dragonborn")
        str=$(( str + 2 ))
        cha=$(( cha + 1 ))
        ;;
    "dwarf")
        con=$(( con + 2 ))
        ;;
    "elf")
        dex=$(( dex + 2 ))
        ;;
    "gnome")
        int=$(( int + 2 ))
        ;;
    "half-elf")
        cha=$(( cha + 2 ))
        ;;
    "half-orc")
        str=$(( str + 2 ))
        con=$(( con + 1 ))
        ;;
    "halfling")
        dex=$(( dex + 2 ))
        ;;
    "human")
        str=$(( str + 1 ))
        dex=$(( dex + 1 ))
        con=$(( con + 1 ))
        int=$(( int + 1 ))
        wis=$(( wis + 1 ))
        cha=$(( cha + 1 ))
        ;;
    "tiefling")
        int=$(( int + 1 ))
        cha=$(( cha + 2 ))
        ;;
esac

case "$race" in
    "half-elf")
        read -r -p "Enter first ability to receive +1 bonus [str/dex/con/int/wis/cha]: " bonus1
        read -r -p "Enter second ability to receive +1 bonus [str/dex/con/int/wis/cha]: " bonus2

        for bonus in "$bonus1" "$bonus2"; do
            if [ -z "$bonus" ]; then
                red_message "Error" "No ability selected."
                exit 1
            fi

            if [ "$bonus1" = "$bonus2" ]; then
                red_message "Error:" "You must choose two different abilities."
                exit 1
            fi

            bonus=$(printf '%s' "$bonus" | tr '[:upper:]' '[:lower:]')

            case "$bonus" in
                "str") str=$(( str + 1 )) ;;
                "dex") dex=$(( dex + 1 )) ;;
                "con") con=$(( con + 1 )) ;;
                "int") int=$(( int + 1 )) ;;
                "wis") wis=$(( wis + 1 )) ;;
                "cha") cha=$(( cha + 1 )) ;;
                *)
                    red_message "Error:" "Unknown ability."
                    exit 1
                    ;;
            esac
        done
        ;;
esac

for ability in str dex con int wis cha; do
    case "$ability" in
        "str") str_mod=$(( (str - 10) / 2 )) ;;
        "dex") dex_mod=$(( (dex - 10) / 2 )) ;;
        "con") con_mod=$(( (con - 10) / 2 )) ;;
        "int") int_mod=$(( (int - 10) / 2 )) ;;
        "wis") wis_mod=$(( (wis - 10) / 2 )) ;;
        "cha") cha_mod=$(( (cha - 10) / 2 )) ;;
    esac
done

print_ability "STR" "$str" "$str_mod"
print_ability "DEX" "$dex" "$dex_mod"
print_ability "CON" "$con" "$con_mod"
print_ability "INT" "$int" "$int_mod"
print_ability "WIS" "$wis" "$wis_mod"
print_ability "CHA" "$cha" "$cha_mod"

hp=$(( hit_die + con_mod ))
green_message "HP:" "$hp"
