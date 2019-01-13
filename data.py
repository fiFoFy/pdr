import http.cookiejar
import urllib.request
from urllib import parse
from bs4 import BeautifulSoup
import os.path
import json


def start_session():
    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(
        urllib.request.HTTPCookieProcessor(cj))
    res = opener.open("http://pdr.hsc.gov.ua/test-pdd/uk/")
    res.read()
    return opener


def get_token(opener):
    res = opener.open(
        'http://pdr.hsc.gov.ua/test-pdd/uk/authorization?target=exam')
    html = BeautifulSoup(res.read(), 'html.parser')
    token = html.find(
        'input', {'id': 'authorization_form__token'}).get('value')
    return token


def login(opener, token):
    data = parse.urlencode({
        'authorization_form[email]': 'marchenko.alexandr@gmail.com',
        'authorization_form[password]': 'test',
        'authorization_form[_token]': token
    }).encode()
    res = opener.open(
        'http://pdr.hsc.gov.ua/test-pdd/uk/check-authorization?target=exam', data)
    res.read()


def set_category(opener):
    data = parse.urlencode({
        'categoryName': 'B'
    }).encode()
    res = opener.open('http://pdr.hsc.gov.ua/set-exam-category', data)
    res.read()


def get_exam(opener):
    res = opener.open('http://pdr.hsc.gov.ua/test-pdd/uk/exam')
    # html = res.read()
    # f = open('/Users/mac/Desktop/acme.html', 'w')
    # f.write(html.decode())
    # f.close()
    html = BeautifulSoup(res.read(), 'html.parser')
    questions = {}

    for q in html.find_all(class_='question'):
        question = {
            'id': q.attrs['data-link_id'].strip(),
            'section': q.attrs['data-section_id'].strip(),
            'question': q.find(class_='text_question').get_text().strip(),
            'image': q.find(class_='small_image_horizontal').attrs['src'].strip(),
            'answers': {}
        }
        for a in q.find(class_='answers').find_all('li'):
            answer = {
                'id': a.find('input').attrs['value'].strip(),
                'answer': a.find('label').get_text().strip()
            }
            question['answers'][answer['id']] = answer
        questions[question['id']] = question
    return questions


def check(opener, question_id, answer_id):
    data = parse.urlencode({
        'answer': answer_id,
        'question': 'question_number_' + str(question_id),
        'page': 'exam',
        'last': '0',
        'totalTimer': '532'
    }).encode()
    res = opener.open(
        'http://pdr.hsc.gov.ua/test-pdd/uk/check-right-answer', data)
    data = json.loads(res.read())
    # print(data)
    return data['right']


def download_if_needed(url):
    file = 'assets/images/' + url.split('/')[-1]
    if not os.path.exists(file):
        urllib.request.urlretrieve(url, file)


def grab(opener):
    data = None
    with open('assets/data.json', 'r', encoding='utf8') as f:
        data = json.loads(f.read())

    questions = get_exam(opener)

    processed = 0
    for id, question in questions.items():
        if id in data:
            continue

        correct = None
        for id, answer in question['answers'].items():
            if correct == None:
                correct = check(opener, question['id'], answer['id'])
                question['correct'] = str(correct)

            if str(correct) == answer['id']:
                answer['correct'] = True
            else:
                answer['correct'] = False

        data[question['id']] = question
        download_if_needed(question['image'])
        processed = processed + 1

    with open('assets/data.json', 'w', encoding='utf8') as f:
        json.dump(data, f, ensure_ascii=False)
    return processed


opener = start_session()
token = get_token(opener)
login(opener, token)
set_category(opener)

for _ in range(20):
    processed = grab(opener)
    print(processed)
