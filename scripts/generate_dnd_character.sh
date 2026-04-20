#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# Based on Dungeons & Dragons 5E (5th edition)

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in bashrc.d
shopt -s globstar nullglob

for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

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

speed=0
hit_die=0
hp=0

race=""
race_uc=""
ancestry=""
ancestry_uc=""
size=""
class=""

race_selection() {
    green_message "Races:"
    printf '%s\n' \
        "[1] Dragonborn" \
        "[2] Dwarf" \
        "[3] Elf" \
        "[4] Gnome" \
        "[5] Half-Elf" \
        "[6] Half-Orc" \
        "[7] Halfling" \
        "[8] Human" \
        "[9] Tiefling" | sed "s/^/  /"

    local num

    while true; do
        read -r -p "Enter race [1-9]: " num

        case "$num" in
            "1")
                race="dragonborn"
                size="Medium"
                speed=30
                ;;
            "2")
                race="dwarf"
                size="Medium"
                speed=25
                ;;
            "3")
                race="elf"
                size="Medium"
                speed=30
                ;;
            "4")
                race="gnome"
                size="Small"
                speed=25
                ;;
            "5")
                race="half-elf"
                size="Medium"
                speed=30
                ;;
            "6")
                race="half-orc"
                size="Medium"
                speed=30
                ;;
            "7")
                race="halfling"
                size="Small"
                speed=25
                ;;
            "8")
                race="human"
                size="Medium"
                speed=30
                ;;
            "9")
                race="tiefling"
                size="Medium"
                speed=30
                ;;
            *) continue ;;
        esac

        race_uc=$(printf '%s' "$race" | sed 's/\b\(.\)/\u\1/g')
        return 0
    done
}

race_variant_selection() {
    green_message "Race Variants:"

    local num

    while true; do
        case "$race" in
            "dwarf")
                printf '%s\n' \
                    "[1] Hill Dwarf" \
                    "[2] Mountain Dwarf" | sed "s/^/  /"

                read -r -p "Enter race variant [1-2]: " num

                case "$num" in
                    "1") race="hill dwarf" ;;
                    "2") race="mountain dwarf" ;;
                    *) continue ;;
                esac
                ;;
            "elf")
                printf '%s\n' \
                    "[1] Dark Elf" \
                    "[2] High Elf" \
                    "[3] Wood Elf" | sed "s/^/  /"

                read -r -p "Enter race variant [1-3]: " num

                case "$num" in
                    "1") race="dark elf" ;;
                    "2") race="high elf" ;;
                    "3")
                        race="wood elf"
                        speed=35
                        ;;
                    *) continue ;;
                esac
                ;;
            "gnome")
                printf '%s\n' \
                    "[1] Forest Gnome" \
                    "[2] Rock Gnome" | sed "s/^/  /"

                read -r -p "Enter race variant [1-2]: " num

                case "$num" in
                    "1") race="forest gnome" ;;
                    "2") race="rock gnome" ;;
                    *) continue ;;
                esac
                ;;
            "halfling")
                printf '%s\n' \
                    "[1] Lightfoot Halfling" \
                    "[2] Stout Halfling" | sed "s/^/  /"

                read -r -p "Enter race variant [1-2]: " num

                case "$num" in
                    "1") race="lightfoot halfling" ;;
                    "2") race="stout halfling" ;;
                    *) continue ;;
                esac
                ;;
        esac

        race_uc=$(printf '%s' "$race" | sed 's/\b\(.\)/\u\1/g')
        return 0
    done
}

draconic_ancestry_selection() {
    green_message "Draconic Ancestry:"
    printf '%s\n' \
        "[1] Black" \
        "[2] Blue" \
        "[3] Brass" \
        "[4] Bronze" \
        "[5] Copper" \
        "[6] Gold" \
        "[7] Green" \
        "[8] Red" \
        "[9] Silver" \
        "[10] White" | sed "s/^/  /"

    local num

    while true; do
        read -r -p "Enter draconic ancestry [1-10]: " num

        case "$num" in
            "1") ancestry="black" ;;
            "2") ancestry="blue" ;;
            "3") ancestry="brass" ;;
            "4") ancestry="bronze" ;;
            "5") ancestry="copper" ;;
            "6") ancestry="gold" ;;
            "7") ancestry="green" ;;
            "8") ancestry="red" ;;
            "9") ancestry="silver" ;;
            "10") ancestry="white" ;;
            *) continue ;;
        esac

        case "$ancestry" in
            "black"|"copper")
                dmg_type="Acid"
                breath_weapon="5 by 30 ft line (DEX save)"
                ;;
            "blue"|"bronze")
                dmg_type="Lightning"
                breath_weapon="5 by 30 ft line (DEX save)"
                ;;
            "brass")
                dmg_type="Fire"
                breath_weapon="5 by 30 ft line (DEX save)"
                ;;
            "red"|"gold")
                dmg_type="Fire"
                breath_weapon="15 ft cone (DEX save)"
                ;;
            "green")
                dmg_type="Poison"
                breath_weapon="15 ft cone (CON save)"
                ;;
            "silver"|"white")
                dmg_type="Cold"
                breath_weapon="15 ft cone (CON save)"
                ;;
        esac

        ancestry_uc=$(printf '%s' "$ancestry" | sed 's/\b\(.\)/\u\1/g')
        return 0
    done
}

ability_score_increase() {
    green_message "Half-Elf Ability Score Increases:"
    printf '%s\n' \
        "[1] STR" \
        "[2] DEX" \
        "[3] CON" \
        "[4] INT" \
        "[5] WIS" \
        "[6] CHA" | sed "s/^/  /"

    local num1 num2 bonus1 bonus2

    while true; do
        read -r -p "Enter first ability [1-6]: " num1
        case "$num1" in
            1) bonus1="str" ;;
            2) bonus1="dex" ;;
            3) bonus1="con" ;;
            4) bonus1="int" ;;
            5) bonus1="wis" ;;
            6) bonus1="cha" ;;
            *) continue ;;
        esac
        break
    done

    while true; do
        read -r -p "Enter second ability [1-6]: " num2
        case "$num2" in
            1) bonus2="str" ;;
            2) bonus2="dex" ;;
            3) bonus2="con" ;;
            4) bonus2="int" ;;
            5) bonus2="wis" ;;
            6) bonus2="cha" ;;
            *) continue ;;
        esac

        if [ "$bonus1" = "$bonus2" ]; then
            red_message "Error:" "You must choose two different abilities."
            continue
        fi

        break
    done

    for ability in "$bonus1" "$bonus2"; do
        case "$ability" in
            str) str=$((str + 1)) ;;
            dex) dex=$((dex + 1)) ;;
            con) con=$((con + 1)) ;;
            int) int=$((int + 1)) ;;
            wis) wis=$((wis + 1)) ;;
            cha) cha=$((cha + 1)) ;;
        esac
    done

    return 0
}

class_selection() {
    green_message "Classes:"
    printf '%s\n' \
        "[1] Barbarian" \
        "[2] Bard" \
        "[3] Cleric" \
        "[4] Druid" \
        "[5] Fighter" \
        "[6] Monk" \
        "[7] Paladin" \
        "[8] Ranger" \
        "[9] Rogue" \
        "[10] Sorcerer" \
        "[11] Warlock" \
        "[12] Wizard" | sed "s/^/  /"

    local num

    while true; do
        read -r -p "Enter class [1-12]: " num

        case "$num" in
            "1") class="barbarian" ;;
            "2") class="bard" ;;
            "3") class="cleric" ;;
            "4") class="druid" ;;
            "5") class="fighter" ;;
            "6") class="monk" ;;
            "7") class="paladin" ;;
            "8") class="ranger" ;;
            "9") class="rogue" ;;
            "10") class="sorcerer" ;;
            "11") class="warlock" ;;
            "12") class="wizard" ;;
            *) continue ;;
        esac

        case "$class" in
            barbarian)
                hit_die=12
                primary_ability="STR"
                saves="STR, CON"
                ;;
            bard)
                hit_die=8
                primary_ability="CHA"
                saves="DEX, CHA"
                ;;
            cleric)
                hit_die=8
                primary_ability="WIS"
                saves="WIS, CHA"
                ;;
            druid)
                hit_die=8
                primary_ability="WIS"
                saves="INT, WIS"
                ;;
            fighter)
                hit_die=10
                primary_ability="STR or DEX"
                saves="STR, CON"
                ;;
            monk)
                hit_die=8
                primary_ability="DEX and WIS"
                saves="STR, DEX"
                ;;
            paladin)
                hit_die=10
                primary_ability="STR and CHA"
                saves="WIS, CHA"
                ;;
            ranger)
                hit_die=10
                primary_ability="DEX and WIS"
                saves="STR, DEX"
                ;;
            rogue)
                hit_die=8
                primary_ability="DEX"
                saves="DEX, INT"
                ;;
            sorcerer)
                hit_die=6
                primary_ability="CHA"
                saves="CON, CHA"
                ;;
            warlock)
                hit_die=8
                primary_ability="CHA"
                saves="WIS, CHA"
                ;;
            wizard)
                hit_die=6
                primary_ability="INT"
                saves="INT, WIS"
                ;;
        esac

        class_uc=$(printf '%s' "$class" | sed 's/\b\(.\)/\u\1/g')
        return 0
    done
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

print_racial_traits() {
    race="$1"
    case "$race" in
        "dark elf")
            printf '%s\n' \
                "Superior Darkvision" \
                "Keen Senses" \
                "Fey Ancestry" \
                "Sunlight Sensitivity" \
                "Drow Magic" \
                "Drow Weapon Training" | sed "s/^/  /"
            ;;
        "dragonborn")
            printf '%s\n' \
                "Draconic Ancestry" \
                "Breath Weapon" \
                "Damage Resistance" | sed "s/^/  /"
            ;;
        "forest gnome")
            printf '%s\n' \
                "Darkvision" \
                "Gnome Cunning" \
                "Natural Illusionist" \
                "Speak with Small Beasts" | sed "s/^/  /"
            ;;
        "half-elf")
            printf '%s\n' \
                "Darkvision" \
                "Fey Ancestry" \
                "Skill Versatility" \
                "Ability Score Increase" | sed "s/^/  /"
            ;;
        "half-orc")
            printf '%s\n' \
                "Darkvision" \
                "Menacing" \
                "Relentless Endurance" \
                "Savage Attacks" | sed "s/^/  /"
            ;;
        "high elf")
            printf '%s\n' \
                "Darkvision" \
                "Keen Senses" \
                "Fey Ancestry" \
                "Trance" \
                "Cantrip" \
                "Elf Weapon Training" \
                "Extra Language" | sed "s/^/  /"
            ;;
        "hill dwarf")
            printf '%s\n' \
                "Darkvision" \
                "Dwarven Resilience" \
                "Dwarven Combat Training" \
                "Tool Proficiency" \
                "Stonecunning" \
                "Dwarven Toughness" | sed "s/^/  /"
            ;;
        "human")
            printf '%s\n' \
                "Extra Language" | sed "s/^/  /"
            ;;
        "lightfoot halfling")
            printf '%s\n' \
                "Lucky" \
                "Brave" \
                "Nimble" \
                "Naturally Stealthy" | sed "s/^/  /"
            ;;
        "mountain dwarf")
            printf '%s\n' \
                "Darkvision" \
                "Dwarven Resilience" \
                "Dwarven Combat Training" \
                "Tool Proficiency" \
                "Stonecunning" \
                "Dwarven Armor Training" | sed "s/^/  /"
            ;;
        "rock gnome")
            printf '%s\n' \
                "Darkvision" \
                "Gnome Cunning" \
                "Artificer's Lore" \
                "Tinker" | sed "s/^/  /"
            ;;
        "stout halfling")
            printf '%s\n' \
                "Lucky" \
                "Brave" \
                "Nimble" \
                "Stout Resilience" | sed "s/^/  /"
            ;;
        "tiefling")
            printf '%s\n' \
                "Darkvision" \
                "Hellish Resistance" \
                "Infernal Legacy" | sed "s/^/  /"
            ;;
        "wood elf")
            printf '%s\n' \
                "Darkvision" \
                "Keen Senses" \
                "Fey Ancestry" \
                "Trance" \
                "Elf Weapon Training" \
                "Fleet of Foot" \
                "Mask of the Wild" | sed "s/^/  /"
            ;;
    esac
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

race_selection

case "$race" in
    "dwarf"|"elf"|"gnome"|"halfling")
        race_variant_selection
        ;;
esac

case "$race" in
    "dragonborn")
        draconic_ancestry_selection
        ;;
esac

class_selection

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
    "dark elf")
        dex=$(( dex + 2 ))
        cha=$(( cha + 1 ))
        ;;
    "dragonborn")
        str=$(( str + 2 ))
        cha=$(( cha + 1 ))
        ;;
    "forest gnome")
        dex=$(( dex + 1 ))
        int=$(( int + 2 ))
        ;;
    "half-elf")
        cha=$(( cha + 2 ))
        ability_score_increase
        ;;
    "half-orc")
        str=$(( str + 2 ))
        con=$(( con + 1 ))
        ;;
    "lightfoot halfling")
        dex=$(( dex + 2 ))
        cha=$(( cha + 1 ))
        ;;
    "high elf")
        dex=$(( dex + 2 ))
        int=$(( int + 1 ))
        ;;
    "hill dwarf")
        con=$(( con + 2 ))
        wis=$(( wis + 1 ))
        ;;
    "human")
        str=$(( str + 1 ))
        dex=$(( dex + 1 ))
        con=$(( con + 1 ))
        int=$(( int + 1 ))
        wis=$(( wis + 1 ))
        cha=$(( cha + 1 ))
        ;;
    "mountain dwarf")
        str=$(( str + 2 ))
        con=$(( con + 2 ))
        ;;
    "rock gnome")
        con=$(( con + 1 ))
        int=$(( int + 2 ))
        ;;
    "stout halfling")
        dex=$(( dex + 2 ))
        con=$(( con + 1 ))
        ;;
    "tiefling")
        int=$(( int + 1 ))
        cha=$(( cha + 2 ))
        ;;
    "wood elf")
        dex=$(( dex + 2 ))
        wis=$(( wis + 1 ))
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

green_message "Race:" "$race_uc"
green_message "Size:" "$size"
green_message "Speed:" "$speed ft"
green_message "Racial Traits:"
print_racial_traits "$race"

case "$race" in
    "dragonborn")
        green_message "Draconic Ancestry:" "$ancestry_uc"
        green_message "Damage Type:" "$dmg_type"
        green_message "Breath Weapon:" "$breath_weapon"
        ;;
esac

green_message "Class:" "$class_uc"
green_message "Hit Die:" "d$hit_die"
green_message "Primary Ability:" "$primary_ability"
green_message "Saves:" "$saves"

print_ability "STR" "$str" "$str_mod"
print_ability "DEX" "$dex" "$dex_mod"
print_ability "CON" "$con" "$con_mod"
print_ability "INT" "$int" "$int_mod"
print_ability "WIS" "$wis" "$wis_mod"
print_ability "CHA" "$cha" "$cha_mod"

hp=$(( hit_die + con_mod ))

case "$race" in
    "hill-dwarf") hp=$(( hp + 1 )) ;;
esac

green_message "HP:" "$hp"
