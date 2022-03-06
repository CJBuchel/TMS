const mysql = require('mysql2');
const { networkInterfaces } = require('os');

export class DatabaseConnection {
  db_config:any;
  db_connection:any;
  constructor(host:string = "localhost", port:number = 3306, user:string = "cjms", password:string = "cjms", database:string = "cjms-database") {
    this.db_config = {
      host: host,
      user: user,
      password: password,
      database: database,
      port: port,
    }
    
    console.log(`User hostname: ${host}`);

    const nets = networkInterfaces();
    const results = Object.create(null);

    for (const name of Object.keys(nets)) {
      for (const net of nets[name]) {
        if (net.family === 'IPv4' && !net.internal) {
          if (!results[name]) {
            results[name] = [];
          }
          results[name].push(net.address);
          host = net.address;
          console.log(net.address);
        }
      }
    }

    // console.log(`User hostname: ${host}`);

    // console.log(results);
    // host = internalIpV4();
    // console.log(internalIpV4());
    // console.log(`Local Host: ${host}`);
  }

  async connect() {
    this.db_connection = await mysql.createConnection(this.db_config);
    console.log("Connected");
  }
}