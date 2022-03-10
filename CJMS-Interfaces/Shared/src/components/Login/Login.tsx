// 
// Generic Shared login
// 
import React, { useCallback } from "react";
import * as Requests from "../Requests/Request";

interface IProps {
  setToken:any,
  allowedUser:any
}

interface IState {
  username:String,
  password:String
}

class Login extends React.Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      username: undefined,
      password: undefined
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

  // @TODO
}