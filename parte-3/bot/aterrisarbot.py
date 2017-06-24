#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from datetime import datetime as dt
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters
# from telegram import KeyboardButton, ReplyKeyboardMarkup
from botlog import log_activity
import pickle
import logging
import pymysql
import telegram

messages = {
    'start': 'Seja bem vindo ao Aterrisar.com!',

    'help': (
        'Olá, este bot pode lhe ajudar com os seguintes comandos:\n\n'
        '/destinos_procurados: mostra os *5 destinos* mais procurados pelos usuários\n\n'
        '/aeroporto_voos: mostra os voos que partem de um aeroporto em uma data\n\n'
    ),

    'inválido': (
        '⚠️ Atenção: *comando inválido!*⚠️:\n\n'
        'em caso de dúvidas, consulte /help'),

    'aeroporto_voo': 'Não há voôs partindo deste aeroporto {}',
    'aeroportos_disp': (
        'Utilização: /aeroporto\_voos *<sigla-aeroporto>* \n\n'
        'Aeroportos disponíveis:\n\n'
    ),

    'voo': (
        'Utilização: /voo *<sigla-aeroporto-origem> <sigla-aeroporto-destino>* \n\n'
        'Aeroportos disponíveis:\n\n'
    )
}

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)

logger = logging.getLogger(__name__)


def execute_sql(query):
    db = pymysql.connect(host='virgiliofernandes.me', user='virgilio', password='lbd', database='lab_bd')
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.execute(query)
    data = cursor.fetchall()
    return data


def error(bot, update, error):
    logger.warning('Update "%s" caused error "%s"' % (update, error))


def build_menu(buttons, n_cols, header_buttons, footer_buttons):
    menu = [buttons[i:i + n_cols] for i in range(0, len(buttons), n_cols)]
    if header_buttons:
        menu.insert(0, header_buttons)
    if footer_buttons:
        menu.append(footer_buttons)
    return menu


def start(bot, update):
    bot.send_message(chat_id=update.message.chat_id, text=messages['start'],
        parse_mode=telegram.ParseMode.HTML)
    log_activity(update)

    # button_list = [
    #     KeyboardButton("Vôo", voo)
    #     # ReplyKeyboardMarkup("col 2", ...),
    #     # ReplyKeyboardMarkup("row 2", ...)
    # ]
    # reply_markup = ReplyKeyboardMarkup(build_menu(button_list, n_cols=2,
    #     header_buttons=None, footer_buttons=None))
    # bot.send_message(chat_id=update.message.chat_id, text="A two-column menu",
    #     reply_markup=reply_markup)


def destinos_procurados(bot, update):
    query = (
        'SELECT via.destinho as destino, aer.sigla, aer.local, aer.nome\n'
        'FROM viagem via, aeroporto aer\n'
        'WHERE via.destinho = aer.sigla\n'
        'GROUP BY destino\n'
        'ORDER BY COUNT(destino) DESC LIMIT 5;\n'
    )

    rows = execute_sql(query)

    if rows:
        title = """*Destinos mais procurados*\n"""
        message = ''
        for position, row in enumerate(rows):
            message += (
                '_{}ª posição_:\n'
                'Destino: *{}*\n'
                'Aeroporto: *{} ({})*\n\n').format(position + 1, row['destino'],
                row['nome'], row['sigla']
            )

        update.message.reply_text(title + message, quote=True,
            parse_mode=telegram.ParseMode.MARKDOWN)

    log_activity(update)


def aeroporto_voos(bot, update, args):
    # print(args)
    if args:
        for aeroporto in args:
            query = (
                'SELECT vo.voo_codigo, vo.origem, aer_o.local as local_origem, aer_o.nome as nome_origem, '
                'vo.data_hora_ini, vo.destino, aer_d.local as local_destino, aer_d.nome as nome_destino\n'
                'FROM voo vo, aeroporto aer_o, aeroporto aer_d\n'
                'WHERE vo.origem = "{origem}"\n'
                'AND vo.origem = aer_o.sigla\n'
                'AND vo.destino = aer_d.sigla;\n'.format(origem=aeroporto)
            )

            # print(query)
            rows = execute_sql(query)
            # print(rows[0])
            if rows:
                title = (
                    '*{nome_origem} ({origem})*\n'
                    'Local: *{local_origem}*\n\n'.format(nome_origem=rows[0]['nome_origem'],
                        origem=rows[0]['origem'], local_origem=rows[0]['local_origem'])
                )

                message = ''

                for row in rows:
                    message += (
                        'Voo: *{voo}*\n'
                        'Destino: *{local_destino}*\n'
                        'Aeroporto: *{nome_origem} ({destino})*\n'
                        'Data: *{data}*\n'
                        'Horário de partida: *{horario}*\n\n'.format(voo=row['voo_codigo'],
                            local_destino=row['local_destino'], nome_origem=row['nome_origem'],
                            destino=row['destino'], data=row['data_hora_ini'].strftime('%d/%m/%Y'),
                            horario=row['data_hora_ini'].strftime('%H:%M'))
                    )

                update.message.reply_text(title + message, quote=True, parse_mode=telegram.ParseMode.MARKDOWN)
            else:
                update.message.reply_text(messages['aeroporto_voo'].format(aeroporto), quote=True)
    else:
        query = 'SELECT sigla, nome, local FROM aeroporto;'
        title = messages['aeroportos_disp']
        rows = execute_sql(query)
        result = ''
        for row in rows:
            # print(row)
            result += (
                '*{nome} ({sigla})*\n'
                # 'Local: *{local}*\n\n'
            ).format(nome=row['nome'], sigla=row['sigla'], local=row['local'])

        # print(title + result)

        update.message.reply_text(title + result, quote=True, parse_mode=telegram.ParseMode.MARKDOWN)

    log_activity(update)


def voo(bot, update, args):
    if not len(args) < 2:
        query = (
            'SELECT voo_codigo, origem, destino, data_hora_ini, preco '
            'FROM voo '
            'WHERE origem = "{}" '
            'AND destino = "{}"'
            # 'AND data_hora_ini = {}'
        ).format(args[0], args[1])

        print(query)
        rows = execute_sql(query)

        title = (
            'Voos disponíveis de de {origem} para {destino}\n'.format(origem=rows[0]['origem'],
                destino=rows[0]['destino'])
        )

        result = ''

        for row in rows:
            result += (
                'Voo: *{voo}*\n'
                'Data: *{data}*\n'
                'Horário de partida: *{horario}*\n'
                'Preço: *R$ {preco}*\n\n'.format(voo=row['voo_codigo'],
                    preco=row['preco'], data=row['data_hora_ini'].strftime('%d/%m/%Y'),
                    horario=row['data_hora_ini'].strftime('%H:%M'))
            )

        update.message.reply_text(title + result, quote=True, parse_mode=telegram.ParseMode.MARKDOWN)
    else:
        query = 'SELECT sigla, nome, local FROM aeroporto;'
        title = messages['voo']
        rows = execute_sql(query)
        result = ''

        for row in rows:
            # print(row)
            result += (
                '*{nome} ({sigla})*\n'
                # 'Local: *{local}*\n\n'
            ).format(nome=row['nome'], sigla=row['sigla'], local=row['local'])

        update.message.reply_text(title + result, quote=True, parse_mode=telegram.ParseMode.MARKDOWN)
    log_activity(update)


def unknown(bot, update):
    update.message.reply_text(messages['inválido'], quote=True,
        parse_mode=telegram.ParseMode.HTML)
    log_activity(update)


def help(bot, update):
    update.message.reply_text(messages['help'], quote=True,
        parse_mode=telegram.ParseMode.MARKDOWN)
    log_activity(update)


def main():
    with open('token', 'rb') as file:
        token = pickle.load(file)

    updater = Updater(token=token)
    dp = updater.dispatcher
    dp.add_handler(CommandHandler('start', start))
    dp.add_handler(CommandHandler('voo', voo, pass_args=True))
    dp.add_handler(CommandHandler('aeroporto_voos', aeroporto_voos, pass_args=True))
    dp.add_handler(CommandHandler('destinos_procurados', destinos_procurados))
    dp.add_handler(CommandHandler('help', help))
    # dp.add_handler(MessageHandler(Filters.text, echo))
    dp.add_handler(MessageHandler(Filters.command, unknown))
    dp.add_error_handler(error)
    updater.start_polling()
    updater.idle()


if __name__ == '__main__':
    print(
        'Start Time:\t{}\tO bot tá Aterrisando.co..., '
        'digo, DECOLANDO! ✈ ✈ ✈'.format(dt.now().strftime("%Y-%m-%d %H:%M:%S"))
    )

    main()
    print('End Time:\t{}\tO bot tá aterrisando! (agora é verdade, ele tá parando) '.format(
        dt.now().strftime("%Y-%m-%d %H:%M:%S")))
