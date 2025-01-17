import math

punctuations = ['.', ',', '?', '!']

def parse_sentence(sentence:str):
    sentnece_split = sentence.split(' ')
    parsed = []

    for word in sentnece_split:
        word_list = list(word)
        print("[parse_sentence]word_list", word_list)
        if word_list[-1] in punctuations:
            punc = word_list[-1]
            word_list.remove(punc)
            parsed.append('')
            for ch in word_list:
                parsed[-1] += ch
            parsed.append(str(punc))

        else:
            parsed.append(word)

    # handle "a dog" and "A dog" case: two words in one block
    if 'dog' in parsed:
        dog_index = parsed.index('dog')
        if dog_index > 0 and parsed[dog_index -1] in ['a', 'A']:
            parsed[dog_index -1] = ' '.join(parsed[dog_index-1:dog_index+1])
            parsed.remove('dog')

    return parsed


def combine_sentence(sentence:list):
    combined = sentence[0]
    sentence.pop(0)
    for word in sentence:
        if word in punctuations:
            combined += word
        else:
            combined += ' ' + word
    
    print(combined)
    return combined


def check_answer(problem:list, response:list):
    isAnswer = False
    if problem == response:
        isAnswer = True
    return isAnswer


# check whether punctuation is wrong
def punctuation_filter(problem:str, response:str):
    punc_wrong = 0
    r_parse = parse_sentence(response)
    p_parse = parse_sentence(problem)

    p_puncs = []
    for item in p_parse:
        if item in punctuations:
            p_puncs.append(item)
    # 없어야 하는데 있는 구두점
    punc_list = []
    for item in r_parse:
        if item in punctuations:
            punc_list.append(item)
            if not (item in p_puncs):
                punc_wrong += 1
                if len(p_puncs) > 0:
                    p_parse.remove(p_puncs.pop(0))
            else:
                p_parse.remove(item)
            
    for item in punc_list:
        r_parse.remove(item)

    # 있어야 하는데 없는 구두점
    punc_list = []
    for item in p_parse:
        if item in punctuations:
            if not (item in r_parse):
                punc_wrong += 1
                punc_list.append(item)
    
    for item in punc_list:
        p_parse.remove(item)

    filteredR = ' '.join(r_parse)
    filteredP = ' '.join(p_parse)
    return punc_wrong, filteredP, filteredR


# check whether letter is wrong
def lettercase_filter(problem:str, response:str):
    letter_wrong = 0
    low_p = problem.lower()
    low_p_split = low_p.split(' ')
    low_r = response.lower()
    low_r_split = low_r.split(' ')

    p_split = problem.split(' ')
    r_split = response.split(' ')

    filterCheckList = [0] * len(r_split)
    for i in range(len(r_split)):
        if not(r_split[i] in p_split) and r_split[i] in low_p_split:
            filterCheckList[i] = 1
            letter_wrong += 1
        if not(r_split[i] in p_split) and low_r_split[i] in p_split:
            filterCheckList[i] = 2
            letter_wrong += 1
        
    
    for i in range(len(filterCheckList)):
        if filterCheckList[i] == 1:
            r_split[i] = p_split[low_p_split.index(r_split[i])]
        elif filterCheckList[i] == 2:
            r_split[i] = p_split[p_split.index(low_r_split[i])]

    filteredR = ' '.join(r_split)
    return letter_wrong, filteredR



def search_log_timestamp(res, action, user_id):
    import re
    from datetime import datetime
    for hit in res['hits']['hits']:
        message = hit['_source']['message']
        timestamp = hit['_source']['@timestamp']
        
        # Extract the information you need using regular expressions
        match = re.search(f'- --- {action} --- - \[user: {user_id}\]', message)
        if match:
            # only need the latest logs end the loop.
            return datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
        else:
            return None
        
        
# Initializing the user's 'temp' problem state.
# Temp problem is needed to calculate the number of incorrect answers given by the user.
def init_user_problem(user_id: str, season: int, level: int, step: int, problem_type: str):
    from problem.schemas import TempUserProblem, TempUserProblems
    TempUserProblems[user_id] = TempUserProblem(0, 0, 0, 0, 0)
    tempUserProblem = TempUserProblems.get(user_id)
    tempUserProblem.solved_season = season
    tempUserProblem.solved_level = level
    tempUserProblem.solved_step = step
    tempUserProblem.solved_type = problem_type