node faq_state {
    has answer;
    can gen_repsonse {
        visitor.response = here.answer;
    }
}

edge faq_answer {
    has answer;
}

graph tesla_faq {
    has anchor faq_root;
    spawn {
        faq_root = spawn node::faq_state;
        answer_1 = spawn node::faq_state(
            answer="To configure your order, you can log into your tesla account."
        );
        answer_2 = spawn node::faq_state(
            answer="To order your own Tesla, visit our Design Studio to explore the latest options."
        );
        answer_3 = spawn node::faq_state(
            answer="You can request a test drive if you are over 25 years old."
        ):
        faq_root -[answer]
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