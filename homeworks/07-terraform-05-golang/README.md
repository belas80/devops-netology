# 7.5. Основы golang  

## Написание кода.  

   1. Программа для перевода метров в футы (1 фут = 0.3048 метр).  
      ```
      package main
      
      import "fmt"
      
      func main() {
          fmt.Print("Enter a number: ")
          var input float32
          fmt.Scanf("%f", &input)
      
          output := input / 0.3048
      
          fmt.Println(output)
      }
      ```
   2. Программа, которая найдет наименьший элемент в любом заданном списке.  
      ```
      package main
      
      import (
          "fmt"
      )
      
      func main() {
          x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
          minNum := x[0]
          for _, i2 := range x[1:] {
              if minNum > i2 {
                  fmt.Println(minNum, " > ", i2)
                  minNum = i2
              } else {
                  fmt.Println(minNum, " < ", i2)
              }
          }
          fmt.Println("minimum number is ", minNum)
      }
      ```
   3. Программу, которая выводит числа от 1 до 100, которые делятся на 3.  
      ```
      package main
      
      import "fmt"
      
      func main() {
      	for i := 1; i <= 100; i++ {
      		if i%3 == 0 {
      			fmt.Println(i)
      		}
      	}
      }
      ```
      
