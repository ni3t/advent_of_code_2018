package main

import (
	"fmt" 
	"os"
	"bufio"
	"strconv"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func main() {
	result := 0
	pwd, err := os.Getwd()
	check(err)
	filePath := pwd + "/problems/1/input.txt"
	file, err := os.Open(filePath)
	check(err)
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		i, _ := parse(scanner.Text())
		result += i
	}
	fmt.Println("Result: " + strconv.Itoa(result))
}

func parse(str string) (int, error) {
	return strconv.Atoi(str) 
}