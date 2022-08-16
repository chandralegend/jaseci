walker conv_ai {
    has question;
    has labels = ["weather", "direction", ""];
    has candidate_answers;
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
            answer = gen_repsonse(intent, entities);

        report answer;
    }
}