package main

import (
	"fmt"
	"log"
	"os/exec"
	"strings"
	"time"
)

const MaxLength = 25
const SleepTime = 500
const ErrorNoPlayersFound = ""

func main() {
	songInfo := getSongInfo()
	if strings.TrimSpace(songInfo) == "-" {
		fmt.Println(ErrorNoPlayersFound)
	} else {
		scroll(songInfo, MaxLength, SleepTime)
	}
}

func scroll(text string, length int, sleepTime int) {
	shifted := text
	prevText := text
	for true {
		prevText = text
		if text != prevText {
			text = prevText
			shifted = prevText
		}
		if len(text) > length {
			if strings.TrimSpace(text) == strings.TrimSpace(shifted) {
				shifted = text + " "
			}
			shifted = shiftLetters(shifted)
			fmt.Println(getShortenedText(addPrefix(shifted)))
		} else {
			fmt.Println(addPrefix(shifted))
			shifted = getSongInfo()
		}
		time.Sleep(time.Duration(sleepTime * int(time.Millisecond)))
	}
}

func getSongInfo() string {
	artist, _ := exec.Command("playerctl", "metadata", "artist").Output()
	song, _ := exec.Command("playerctl", "metadata", "title").Output()
	text := strings.ReplaceAll(string(artist)+" - "+string(song), "\n", "")
	return text
}

func addPrefix(text string) string {
	var prefix string
	out, err := exec.Command("playerctl", "status").Output()
	if err != nil {
		log.Fatal(err)
	}
	if strings.TrimSuffix(string(out), "\n") == "Paused" {
		prefix = " "
	} else {
		prefix = " "
	}
	return prefix + " " + text
}

func getShortenedText(text string) string {
	chars := []rune(text)
	var shortened string
	for i := 0; i < len(chars); i++ {
		shortened += string(chars[i])
		if i >= MaxLength {
			break
		}
	}
	return shortened
}

func shiftLetters(text string) string {
	text = strings.ReplaceAll(text, "\n", "")
	chars := []rune(text)
	var shifted string
	for i := 0; i < len(chars); i++ {
		if i+1 == len(chars) {
			shifted += string(chars[0])
			break
		}
		shifted += string(chars[i+1])
	}
	return shifted
}
