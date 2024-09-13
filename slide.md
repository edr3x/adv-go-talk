---
title: Advanced Golang
author: Anuj Dhungana
options:
  end_slide_shorthand: true
  implicit_slide_ends: true
---

# Advanced golang

## Not for golang beginner

### Topic to be discussed

- Goroutene
- Waitgroups
- Mutex
- Channels
- sync.Once
- Interface

Goroutene
=========

```go +exec
package main

import (
    "log"
)

func foo() {
    log.Println("hello from foo")
}

func main() {
    go foo() // run function in another process
    
    log.Println("hello")
}
```

Goroutene
=========

```go +exec
package main

import (
    "log"
    "time"
)

func foo() {
    log.Println("hello from foo")
}

func main() {
    go foo() // run function in another process
    
    time.Sleep(2 *time.Second)
    
    log.Println("hello")
}
```

Waitgroup
=========

```go +exec
package main

import (
    "log"
    "sync"
)

func foo(wg *sync.WaitGroup) {
    defer wg.Done()

    log.Println("hello from foo")
}

func main() {
    var wg sync.WaitGroup

    wg.Add(1)

    go foo(&wg)

    wg.Wait()

    log.Println("hello")
}
```

Waitgroup
=========

### Loop

```go +exec
package main

import (
    "log"
    "time"
)

func foo(x int) {
    time.Sleep(400 * time.Millisecond)
    log.Println(x)
}

func main() {
    for i := 0; i < 10; i++ {
        foo(i)
    }
    
    log.Println("hello")
}
```

Waitgroup
=========

### Loop + goroutene

```go +exec
package main

import (
    "log"
    "time"
)

func foo(x int) {
    time.Sleep(400 * time.Millisecond)
    log.Println(x)
}

func main() {
    for i := 0; i < 10; i++ {
        go foo(i)
    }
    
    log.Println("hello")
}
```

Waitgroup
=========

### Loop + Goroutene + Waitgroup

```go +exec
package main

import (
    "log"
    "sync"
    "time"
)

func foo(x int, wg *sync.WaitGroup) {
    defer wg.Done()
    time.Sleep(400 * time.Millisecond)
    log.Println(x)
}

func main() {
    var wg sync.WaitGroup

    for i := 0; i < 10; i++ {
        wg.Add(1)
        go foo(i, &wg)
    }

    wg.Wait()
    
    log.Println("hello")
}
```

Mutex
========

### Without Mutex

```go +exec
package main

import (
    "fmt"
    "sync"
)

var counter int

func increment(wg *sync.WaitGroup) {
    defer wg.Done()

    for i := 0; i < 1000; i++ {
        counter++
    }
}

func main() {
    var wg sync.WaitGroup

    for i := 0; i < 10; i++ {
        wg.Add(1)
        go increment(&wg)
    }
    wg.Wait()
    fmt.Println("Final Counter:", counter)
}
```

Mutex
========

### With Mutex
```go +exec
package main

import (
    "fmt"
    "sync"
)

var (
    counter int
    mu      sync.Mutex
)

func increment(wg *sync.WaitGroup) {
    defer wg.Done()

    for i := 0; i < 1000; i++ {
        mu.Lock()
        counter++
        mu.Unlock()
    }
}

func main() {
    var wg sync.WaitGroup

    for i := 0; i < 10; i++ {
        wg.Add(1)
        go increment(&wg)
    }
    wg.Wait()

    fmt.Println("Final Counter:", counter)
}
```

Channels
========

```go +exec
package main

import (
    "log"
)

func foo(done chan bool) {
    log.Println("hello from foo")
    
    done <- true
}

func main() {
    done := make(chan bool)
    defer close(done)

    go foo(done)

    log.Println("before done")
    
    <-done

    log.Println("hello")
}
```

Channels
========

### Passing values from goroutene

```go +exec
package main

import (
    "log"
    "time"
)

func main() {
   ch := make(chan string)
   defer close(ch)

   name := "joe"

   go foo(name, ch)

   read := <-ch

   log.Println(read)
}

func foo(name string, ch chan string) {
    time.Sleep(2 * time.Second)

    ch <- "the name provided is: " + name
}
```

Channels
========

### Retruning and Receiving channels

```go +exec
package main
import (
    "log"
    "time"
)
func main() {
    ch1 := make(chan string)
    ch2 := make(chan string)
    defer func() {
        close(ch1)
        close(ch2)
    }()
    
    name := "joe"
    go foo(name, ch1)
    go bar(ch1, ch2)
    read := <-ch2
    log.Println(read)
}

func foo(name string, ch chan string) {
    time.Sleep(2 * time.Second)
    ch <- "the name provided is: " + name
}

func bar(
    ch1 <-chan string, // receiving channel
    ch2 chan<- string, // sending channel
) {
    x := <-ch1
    ch2 <- "received: " + x + " from ch1 channel"
}
```

Once
====

### Sample handler for a server

```go +exec
package main
import (
    "log"
)

type UserService struct{
    db string
}
func NewUserService() *UserService {
    log.Println("hello there")
    return &UserService{
        db: "asdf",
    }
}

func main() {
    handler1()
    handler2()
}

func handler1() {
    NewUserService()
}

func handler2() {
    NewUserService()
}
```


Once
====

### Sample handler for a server

```go +exec
package main
import (
    "log"
    "sync"
)

var usrSvc *UserService
var once   sync.Once

type UserService struct {
    db string
}
func NewUserService() *UserService {
    once.Do(func() {
        log.Println("This only runs once even if called many times")
        usrSvc = &UserService{
            db: "asdf",
        }
    })
    return usrSvc
}

func main() {
    handler1()
    handler2()
}

func handler1() {
    NewUserService()
}
func handler2() {
    NewUserService()
}
```

Interface
=========

## Example1
```go
type IUser interface {
    Print()
    UpdateFirstName(name string)
}

type User struct {
    FirstName string
    LastName  string
}

func NewUser(firstName string, lastName string) IUser {
    return &User{
        FirstName: firstName,
        LastName:  lastName,
    }
}

func (u *User) Modify() {
    u.FirstName = "General " + u.FirstName
}

func (u *User) Print() {
    u.Modify()
    fmt.Println(u.FirstName + " " + u.LastName)
}

func (u *User) UpdateFirstName(firstname string) {
    u.FirstName = firstname
}

func main() {
    usr := NewUser("john", "doe")
    usr.Print()
}
```

Interface
=========

## Wrapping `error` interface

```go
package main

import (
    "fmt"
    "runtime"
)

type CustomError struct {
    Caller  string
    Message string
}

func (e CustomError) Error() string {
    return fmt.Sprintf("%s", e.Message)
}

func NewError(msg string) CustomError {
    pc, _, line, _ := runtime.Caller(1)
    details := runtime.FuncForPC(pc)
    return CustomError{
        Message: msg,
        Caller:  fmt.Sprintf("%s#%d", details.Name(), line),
   }
}

func main() {
    if err := foo(7); err != nil {
        cerr, ok := err.(CustomError)
        if !ok {
            fmt.Println("ERROR: ", err)
            return
        }
        fmt.Println("ERROR:", err.Error(), "from: ", cerr.Caller)
        return
    }
    fmt.Println("no error")
}

func foo(x int64) error {
    if x == 7 {
        return NewError("got 7 thus is error")
    }
    return nil
}
```

THE END
=======

# Any Questions ?

