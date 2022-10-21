import React, { useEffect, useState } from "react";
// import Calculator, {CategoricalScore, NumericScore, Score, ScoreAnswer} from "ausfll-score-calculator";
import Calculator from "ausfll-score-calculator";
import TextField from "@mui/material/TextField";
import TableRow from "@mui/material/TableRow";
import TableCell from "@mui/material/TableCell";
import Radio from "@mui/material/Radio";
import RadioGroup from "@mui/material/RadioGroup";
import FormControlLabel from "@mui/material/FormControlLabel";
const NumericQuestion = ({ question, value, errors, onChange }) => {
    return (React.createElement(TableRow, { sx: { background: 'white' } },
        React.createElement(TableCell, { sx: errors?.length ? { border: 'none', fontWeight: 'bold' } : { border: 'none' } },
            React.createElement("div", { style: { display: 'flex', flexDirection: 'column', alignItems: 'flex-start' } },
                React.createElement("span", null, question.label),
                errors?.map((e, i) => (React.createElement("span", { style: errors?.length ? { border: 'none', fontWeight: 'bold', color: 'red' } : { border: 'none' }, key: i }, e))))),
        React.createElement(TableCell, { sx: { border: 'none', display: 'flex', flexWrap: 'wrap' } }, onChange ? (React.createElement(TextField, { type: "number", value: value ?? question.defaultValue, InputProps: {
                inputProps: { max: question.max, min: question.min },
            }, onChange: (e) => onChange(e.target.value) })) : (React.createElement("span", null, value ?? "?")))));
};
const CategoricalQuestion = ({ question, value, onChange, errors }) => {
    const [val, setVal] = useState(value);
    const handleChange = (s) => {
        if (!onChange)
            return;
        setVal(s);
        onChange(s);
    };
    useEffect(() => {
        setVal(value);
    }, [value]);
    return (React.createElement(TableRow, { sx: { background: 'white' } },
        React.createElement(TableCell, { sx: errors?.length ? { border: 'none', fontWeight: 'bold' } : { border: 'none' } },
            React.createElement("div", { style: { display: 'flex', flexDirection: 'column', alignItems: 'flex-start' } },
                React.createElement("span", null, question.label),
                errors?.map((e, i) => (React.createElement("span", { style: errors?.length ? { border: 'none', fontWeight: 'bold', color: 'red' } : { border: 'none' }, key: i }, e))))),
        React.createElement(TableCell, { sx: { border: 'none', display: 'flex', flexWrap: 'wrap' } },
            React.createElement(RadioGroup, { row: true, value: val ?? null, onChange: (e) => (onChange ? handleChange(e.target.value) : {}) }, question.options.map((opt, key) => (React.createElement(FormControlLabel, { key: key, value: opt, control: React.createElement(Radio, null), label: String(opt).replace(/_/g, " ") })))))));
};
export const Question = ({ question, value, errors, ...rest }) => {
    return Calculator.GIsCategoricalScore(question) ? (React.createElement(CategoricalQuestion, { question: question, value: value, errors: errors?.filter((x, i, a) => a.indexOf(x) === i), ...rest })) : (React.createElement(NumericQuestion, { question: question, value: value, errors: errors?.filter((x, i, a) => a.indexOf(x) === i), ...rest }));
};
export default Question;
