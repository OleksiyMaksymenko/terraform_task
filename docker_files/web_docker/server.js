const express = require('express');
const app = express();
const port = 3000;


app.get('/', (req, res)=>{
    res.send('<h1>Hello world</h1>');
});


app.get('/products', (req, res)=>{
    res.send([
        {
            product:"MB CLS 63s amg",
            engine: 5.5
        },
        {
            product:"Porshe Panamer",
            engine: 6.3
        }
    ]);
});

app.listen(port, ()=>{
    console.log('start '+ port);
})