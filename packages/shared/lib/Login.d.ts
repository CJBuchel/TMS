/// <reference types="react" />
import PropTypes from 'prop-types';
import "./Buttons.css";
import "./Login.css";
declare function Login({ setToken }: {
    setToken: any;
}): JSX.Element;
declare namespace Login {
    var propTypes: {
        setToken: PropTypes.Validator<(...args: any[]) => any>;
    };
}
export default Login;
