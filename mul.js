function grow(x){
    return x.reduce((sum, n) => sum *= n, 1)
  }


  const grow=x=> x.reduce((a,b) => a*b);