package main
import "C"
//export fun
func fun(x int,y int) int{
    return x+y
}

func main(){}
