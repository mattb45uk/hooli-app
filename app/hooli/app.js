const express = require('express');                                                                                        
const bodyParser = require('body-parser')                                                                                  
const app = express();                                                                                                     
const listenPort = 8080;                                                                                                   
                                                                                                                           
app.use(bodyParser.urlencoded({ extended: false }))                                                                        
app.use(bodyParser.json())                                                                                                 
                                                                                                                           
// Ping request                                                                                                            
app.get('/ping',  (req,res,next) => {                                                                                      
                                                                                                                           
    res.send({"result": "pongo"})                                                                                           
                                                                                                                           
});                                                                                                                        
                                                                                                                           
app.listen(listenPort, () => console.log("Server is Running on " + listenPort)); 