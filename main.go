package main

import "log"

func main() {
	foo()
    foo()
	var b = kipuy()
	log.Println(b)
	a := bar()
	log.Println(a)
	a = capal()
	log.Println(a)
	c := amin() + kim() + bar()
	log.Println(c)

	myUser := User{}
	myUser.GetName()
}

func foo() {
	baz()
	yeah()
}

func yeah() {
	nooo()
}

func kim() int {
	nooo()
	return 1
}

func kipuy() int {
	return 1
}

func amin() int {
	return 1
}

func capal() int {
	return 1
}

func bar() int {
	return 1
}

func baz() {
    nooo()
}

func nooo() {}

type User struct {
	name string
}

func (u *User) GetName() string  {
	return u.name
}
