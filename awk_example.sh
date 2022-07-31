func round(n) {
    n=n+0.5
    n=int(n)
    return n
}

/^w/ $$ $2>9000 {print $1,round($2/1024)"k"}

## %s print string
## %d print int
func printlist(n) {
    for(i=1;i<=n;i++) {
        printf("%d ", i) 
    }
    printf("\n")
}

{printlist($1)}