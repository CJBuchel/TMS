/// <reference types="react" />
import PropTypes from 'prop-types';
import "../../assets/stylesheets/Login.scss";
declare function Login({ setToken, allowedUsers }: {
    setToken: any;
    allowedUsers: any;
}): JSX.Element;
declare namespace Login {
    var propTypes: {
        setToken: PropTypes.Validator<(...args: any[]) => any>;
    };
}
export default Login;
