import React, { useEffect, useState, Component } from "react";
// import Calculator, {CategoricalScore, NumericScore, Score, ScoreAnswer} from "ausfll-score-calculator";
import Calculator from "ausfll-score-calculator";
import { CategoricalScore, NumericScore, Score, ScoreAnswer } from "ausfll-score-calculator/dist/game-types";

import TextField from "@mui/material/TextField";
import TableRow from "@mui/material/TableRow";
import TableCell from "@mui/material/TableCell";
import Radio from "@mui/material/Radio";
import RadioGroup from "@mui/material/RadioGroup";
import FormControlLabel from "@mui/material/FormControlLabel";
import { border, fontFamily } from "@mui/system";

type BaseProps = {
  question: Score;
  value?: ScoreAnswer["answer"];
  unanswered: boolean;
  onChange?: (v: ScoreAnswer["answer"]) => void;
  errors?: string[];
}

type NumericProps = BaseProps & {
  question: NumericScore;
}

const NumericQuestion = ({question, value, errors, onChange}: NumericProps) => {
  return (
    <TableRow sx={{background: 'white'}}>
      <TableCell sx={errors?.length ? {border: 'none', fontWeight: 'bold'} : {border: 'none'}}>
        <div style={{display: 'flex', flexDirection: 'column', alignItems: 'flex-start'}}>
          <span>{question.label}</span>
          {errors?.map((e, i) => (
            <span style={errors?.length ? {border: 'none', fontWeight: 'bold', color: 'red'} : {border: 'none'}} key={i}>{e}</span>
          ))}
        </div>
      </TableCell>
      <TableCell sx={{border: 'none', display: 'flex', flexWrap: 'wrap'}}>
        {onChange ? (
          <TextField
            type="number"
            value={value ?? question.defaultValue}
            InputProps={{
              inputProps: { max: question.max, min: question.min },
            }}
            onChange={(e) => onChange(e.target.value)}
          />
        ) : (
          <span>{value ?? "?"}</span>
        )}
      </TableCell>
    </TableRow>
  );
}

type CategoricalProps = BaseProps & {
  question: CategoricalScore;
}

const CategoricalQuestion = ({question, value, onChange, errors}: CategoricalProps) => {
  const [val, setVal] = useState<string | undefined>(value);

  const handleChange = (s: string) => {
    if (!onChange) return;
    setVal(s);
    onChange(s);
  }

  useEffect(() => {
    setVal(value);
  }, [value]);

  return (
    <TableRow sx={{background: 'white'}}>
      <TableCell sx={errors?.length ? {border: 'none', fontWeight: 'bold'} : {border: 'none'}}>
        <div style={{display: 'flex', flexDirection: 'column', alignItems: 'flex-start'}}>
          <span>{question.label}</span>
          {errors?.map((e, i) => (
            <span style={errors?.length ? {border: 'none', fontWeight: 'bold', color: 'red'} : {border: 'none'}} key={i}>{e}</span>
          ))}
        </div>
      </TableCell>
      <TableCell sx={{border: 'none', display: 'flex', flexWrap: 'wrap'}}>
        <RadioGroup
          row
          value={val ?? null}
          onChange={(e) => (onChange ? handleChange(e.target.value) : {})}
        >
          {question.options.map((opt, key) => (
            <FormControlLabel
              key={key}
              value={opt}
              control={<Radio />}
              label={String(opt).replace(/_/g, " ")}
            />
          ))}
        </RadioGroup>
      </TableCell>
    </TableRow>
  );
}

export const Question = ({question, value, errors, ...rest}: BaseProps) => {
  return Calculator.GIsCategoricalScore(question) ? (
    <CategoricalQuestion
      question={question}
      value={value as string}
      errors={errors?.filter((x,i,a) => a.indexOf(x) === i)}
      {...rest}
    />
  ) : (
    <NumericQuestion
      question={question}
      value={value}
      errors={errors?.filter((x, i, a) => a.indexOf(x) === i)}
      {...rest}
    />
  );
}



export default Question;