import PropTypes from 'prop-types';
import "../../assets/stylesheets/Login.scss";
declare function Login({ setToken, allowedUser }: {
    setToken: any;
    allowedUser: any;
}): JSX.Element;
declare namespace Login {
    var propTypes: {
        setToken: PropTypes.Validator<(...args: any[]) => any>;
    };
}
export default Login;
