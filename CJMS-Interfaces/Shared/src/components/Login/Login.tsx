// 
// Generic Shared login
// 
import React, { useCallback } from "react";
import Select from 'react-select';
import * as Requests from "../Requests/Request";

interface IProps {
  setToken:any,
  allowedUser:any
}

interface IState {
  username:String,
  password:String,
  userOptions:any
}

export class Login extends React.Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      username: undefined,
      password: undefined,
      userOptions: [
        {value: 'admin', label: 'Admin'},
        {value: 'scorekeeper', label: 'Score Keeper'},
        {value: 'referee', label: 'Referee'},
        {value: 'head_referee', label: 'Head Referee'}
      ]
    }
  }

  async loginUser(credentials, allowedUser) {
    if (credentials.user !== allowedUser && credentials.user !== 'admin') {
      alert("User [" + credentials.user + "] is not permitted on this page");
      return false;
    } else {
      return Requests.CJMS_REQUEST_LOGIN(credentials);
    }
  }

  handleSubmit = async (e:any) => {
    e.preventDefault();
    const token:any = await this.loginUser({
      username: this.state.username,
      password: this.state.password
    }, this.props.allowedUser)

    if (token) {
      this.props.setToken(token);
    }
  }

  onUserChange = (user:string) => {
    this.setState({username: user});
    console.log("Selected User: " + this.state.username);
  }

  render() {
    return (
      <div className="Login">
        <form onSubmit={this.handleSubmit}>
          <label>User</label>
          <Select onChange={(e:any) => this.onUserChange(e.value)} options={this.state.userOptions}/>
          <label>Password</label>
          <input type="password" onChange={(e:any) => this.setState({password: e.target.value})}/>
          <div>
            <button className="buttonGreen" type="submit">Submit</button>
          </div>
        </form>
      </div>
    );
  }
}