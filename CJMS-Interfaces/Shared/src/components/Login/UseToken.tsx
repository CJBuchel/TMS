import { useState } from "react";

export default function useToken() {
  const getToken = () => {
    const tokenString:any = sessionStorage.getItem('token');
    const userToken = JSON.parse(tokenString);
    if (userToken && userToken.token) {
      return userToken.token;
    }
  }

  const [token, setToken] = useState(getToken());
  const saveToken = (userToken:any) => {
    sessionStorage.setItem('token', JSON.stringify(userToken));
    setToken(userToken.token);
  }

  return { setToken: saveToken, token }
}