node state {
    has state_name;
    can gen_repsonse {
        # Generating natural language response
    }
}

walker conv_ai {
    has question;
    has candidate_answers;
    can bi_enc.infer, tfm_ner.extract_entity, use_qa.qa_classify;
    with entry {
        candidate_answers = file.load_json("answers.json");
        question = std.input(">");
    }
    state {
        intent = bi_enc.infer(contexts=question, candidates=labels);
        entities = tfm_ner.extract_entity(text=question);

        if(intent == "faq"):
            answer = use_qa.qa_classify(text=question, classes=candidate_answers);
        else:
            ::gen_repsonse;

        report answer;
    }
}