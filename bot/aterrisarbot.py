#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from datetime import datetime as dt
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters
from telegram import ReplyKeyboardMarkup
import logging
import pickle
import pymysql
import telegram
import utils as u


class aterrisar_bot:
    def __init__(self, conexao):
        self.conexao = conexao
        self.messages = {
            'start': (
                'Olá, {}, seja bem vindo!\n\n'
                'Sou o Aterrisar-Bot-Com e não há nada no mundo que me alegre mais do que lhe servir.\n'
                'Clique em alguma das opções que eu lhe sugeri abaixo:'
            ),

            'help': (
                'Olá, aqui é a seção de ajuda do Aterrisar-Bot-Com:\n\n'
                'Os comandos aceitos pelo serviço são:\n\n'
                '/destinos\_procurados: mostra os *5 destinos* mais procurados pelos usuários\n\n'
                '/aeroporto\_voos: mostra os voos que partem de um aeroporto em uma data\n\n'

                '/start: faz com que eu mostre as opções disponíveis\n\n'
                '/destinos\_procurados: mostra os *cinco destinos* mais procurados pelos usuários\n\n'
                # '/voo: exibe um voo entre dois locais\n\n'
                '/aeroporto\_voos: mostra os vôos de um determinado aeroporto\n\n'
                '/help: recursão /help(/help) 😱'
            ),

            'inválido': (
                '⚠️ Atenção: *comando inválido!*⚠️:\n\n'
                'Você digitou um comando errado e o mundo vai explodir.\n\n'
                'Em caso de dúvidas, clique aqui  → /help'
            ),

            'aeroporto_voo': (
                'Não há voôs partindo deste aeroporto.'
            ),

            'aeroportos_disp': (
                'Utilização: /aeroporto\_voos *<sigla-aeroporto>* \n\n'
                'Aeroportos disponíveis:\n\n'
            ),

            'voo': (
                'Você precisa escolher um aeroporto: \n\n'
                'Aeroportos disponíveis:\n\n'
            ),

            'nao_voo': (
                'Não há voos disponíveis entre *{}* e *{}* 😢'
            ),

            'tipo_inválido': (
                'O parâmetro deve ser *numérico.* Tente novamente!'
            )
        }

        logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                            level=logging.INFO)

        self.logger = logging.getLogger(__name__)

        self.command_buffer = None
        self.args = []
        self.reply_keyboard = [['Destinos mais procurados'], ['Voos em um aeroporto'], ['Ajuda']]

    def execute_query(self, query):
        db = pymysql.connect(host=self.conexao['host'], user=self.conexao['user'],
            password=self.conexao['password'], database=self.conexao['database'])
        cursor = db.cursor(pymysql.cursors.DictCursor)
        cursor.execute(query)
        data = cursor.fetchall()
        return data

    def error(self, bot, update, error):
        print(self.logger.warning('aterrisarboy.py\nERROR: "%s"\nUPDATE: "%s"\n' % (error, update)))

    def start(self, bot, update):
        self.args = []

        update.message.reply_text(text=self.messages['start'].format(
            update.message.chat.first_name), quote=True,
            reply_markup=ReplyKeyboardMarkup(self.reply_keyboard, one_time_keyboard=True),
            parse_mode=telegram.ParseMode.HTML)

        u.log_activity(update)

    def destinos_procurados(self, bot, update):
        query = (
            'SELECT via.destinho as destino, aer.sigla, aer.local, aer.nome '
            'FROM viagem via, aeroporto aer '
            'WHERE via.destinho = aer.sigla '
            'GROUP BY destino '
            'ORDER BY COUNT(destino) DESC LIMIT 5;'
        )

        print(query)
        rows = self.execute_query(query)

        if rows:
            title = """*Destinos mais procurados*\n\n"""
            message = ''
            for position, row in enumerate(rows):
                message += (
                    '_{}ª posição_:\n'
                    'Destino: *{}*\n'
                    'Aeroporto: *{} ({})*\n\n').format(position + 1, row['local'],
                    row['nome'], row['sigla']
                )

            update.message.reply_text(title + message, quote=True,
                parse_mode=telegram.ParseMode.MARKDOWN,
                reply_markup=ReplyKeyboardMarkup(self.reply_keyboard, one_time_keyboard=True))

        u.log_activity(update)

    def aeroporto_voos(self, bot, update, args):
        if args:
            for aeroporto in args:
                query = (
                    'SELECT vo.voo_codigo, vo.origem, aer_o.local as local_origem, aer_o.nome as nome_origem, '
                    'vo.data_hora_ini, vo.destino, aer_d.local as local_destino, aer_d.nome as nome_destino '
                    'FROM voo vo, aeroporto aer_o, aeroporto aer_d '
                    'WHERE vo.origem = "{origem}" '
                    'AND vo.origem = aer_o.sigla '
                    'AND vo.destino = aer_d.sigla;'.format(origem=aeroporto)
                )

                print(query)
                rows = self.execute_query(query)
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

                    update.message.reply_text(title + message, quote=True, parse_mode=telegram.ParseMode.MARKDOWN,
                        reply_markup=ReplyKeyboardMarkup(self.reply_keyboard, one_time_keyboard=True))
                    self.args = []
                else:
                    update.message.reply_text(self.messages['aeroporto_voo'].format(aeroporto), quote=True,
                        reply_markup=ReplyKeyboardMarkup(self.reply_keyboard, one_time_keyboard=True))

                self.args = []
        else:
            query = 'SELECT sigla, nome, local FROM aeroporto;'
            title = self.messages['aeroportos_disp']
            rows = self.execute_query(query)
            result = ''

            reply_keyboard = []

            for row in rows:
                reply_keyboard += [['{} ({})'.format(row['nome'], row['sigla'])]]

            update.message.reply_text(title + result, quote=True,
                reply_markup=ReplyKeyboardMarkup(reply_keyboard, one_time_keyboard=True),
                parse_mode=telegram.ParseMode.MARKDOWN)

            self.command_buffer = self.aeroporto_voos

        u.log_activity(update)

    def voo(self, bot, update, args):
        print(len(self.args))
        print(self.command_buffer)
        if len(args) == 2:
            query = (
                'SELECT voo_codigo, origem, destino, data_hora_ini, preco '
                'FROM voo '
                'WHERE origem = "{}" '
                'AND destino = "{}"'
            ).format(args[0], args[1])
            print(query)
            rows = self.execute_query(query)
            title = ''
            result = ''
            if rows:
                title = (
                    'Voos disponíveis partindo de *{origem}* até *{destino}*\n'.format(origem=rows[0]['origem'],
                        destino=rows[0]['destino'])
                )

                self.args = []
                for row in rows:
                    result += (
                        'Voo: *{voo}*\n'
                        'Data: *{data}*\n'
                        'Horário de partida: *{horario}*\n'
                        'Preço: *R$ {preco}*\n\n'.format(voo=row['voo_codigo'],
                            preco=row['preco'], data=row['data_hora_ini'].strftime('%d/%m/%Y'),
                            horario=row['data_hora_ini'].strftime('%H:%M'))
                    )

                else:
                    result = self.messages['nao_voo'].format(args[0], args[1])
                    self.args = []

            update.message.reply_text(title + result, quote=True, parse_mode=telegram.ParseMode.MARKDOWN)
        elif len(args) == 1:
            query = 'SELECT sigla, nome, local FROM aeroporto;'
            message = 'Escolha o local de *destino*:\n\n'
            rows = self.execute_query(query)

            reply_keyboard = []

            for row in rows:
                reply_keyboard += [['{} ({})'.format(row['nome'], row['sigla'])]]

            update.message.reply_text(message, quote=True,
                reply_markup=ReplyKeyboardMarkup(reply_keyboard, one_time_keyboard=True),
                parse_mode=telegram.ParseMode.MARKDOWN)

            self.voo(bot, update, self.args)
        else:
            query = 'SELECT sigla, nome, local FROM aeroporto;'
            message = 'Escolha o local de *origem*:\n\n'
            rows = self.execute_query(query)

            reply_keyboard = []

            for row in rows:
                reply_keyboard += [['{} ({})'.format(row['nome'], row['sigla'])]]

            update.message.reply_text(message, quote=True,
                reply_markup=ReplyKeyboardMarkup(reply_keyboard, one_time_keyboard=True),
                parse_mode=telegram.ParseMode.MARKDOWN)

            self.command_buffer = self.voo
        u.log_activity(update)

    def check_users(self, bot, update, args):
        if args:
            try:
                int(args[0])
            except ValueError:
                update.message.reply_text(self.messages['tipo_inválido'], quote=True,
                parse_mode=telegram.ParseMode.MARKDOWN,
                reply_markup=ReplyKeyboardMarkup(self.reply_keyboard, one_time_keyboard=True))
                return

        users, total = u.check_users(int(args[0]) if args else 0)

        header = 'Mostrando os <b>{}/{}</b> últimos usuários do sistema:\n\n'.format(len(users), total)

        footer = '\nUsuários listados: <b>{}/{}</b>\n\n'.format(len(users), total)
        message = ''

        for user in reversed(users):
            message += ('Nome: <b>{}</b>\n').format(user['first'])

            if user['username']:
                message += 'Username: @{}\n'.format(user['username'])

            message += 'Última utilização: {}\n'.format(user['date'].strftime("%a, %d %b %X"))

            message += '\n'

        update.message.reply_text(header + message + footer, quote=True,
            parse_mode=telegram.ParseMode.HTML,
            reply_markup=ReplyKeyboardMarkup(self.reply_keyboard, one_time_keyboard=True))

    def unknown(self, bot, update):
        update.message.reply_text(self.messages['inválido'], quote=True,
            parse_mode=telegram.ParseMode.MARKDOWN,
            reply_markup=ReplyKeyboardMarkup(self.reply_keyboard, one_time_keyboard=True))
        u.log_activity(update)

    def help(self, bot, update):
        update.message.reply_text(self.messages['help'], quote=True,
            parse_mode=telegram.ParseMode.MARKDOWN,
            reply_markup=ReplyKeyboardMarkup(self.reply_keyboard, one_time_keyboard=True))
        u.log_activity(update)

    def echo(self, bot, update):
        if self.command_buffer:
            self.command_buffer(bot, update, [update.message.text[-4: -1]])
            self.command_buffer = None
        else:
            if update.message.text in ['Destinos mais procurados', 'Voos', 'Voos em um aeroporto', 'Ajuda']:
                if update.message.text == 'Destinos mais procurados':
                    self.destinos_procurados(bot, update)
                if update.message.text == 'Voos em um aeroporto':
                    self.aeroporto_voos(bot, update, self.args)
                if update.message.text == 'Ajuda':
                    self.help(bot, update)


def main():
    with open('bot/token', 'rb') as file:
        config = pickle.load(file)

    bot = aterrisar_bot(config.get('conexao'))

    updater = Updater(token=config.get('token'))
    dp = updater.dispatcher
    dp.add_handler(CommandHandler('start', bot.start))
    dp.add_handler(CommandHandler('voo', bot.voo, pass_args=True))
    dp.add_handler(CommandHandler('aeroporto_voos', bot.aeroporto_voos, pass_args=True))
    dp.add_handler(CommandHandler('destinos_procurados', bot.destinos_procurados))
    dp.add_handler(CommandHandler('users', bot.check_users, pass_args=True))
    dp.add_handler(CommandHandler('help', bot.help))
    dp.add_handler(MessageHandler(Filters.text, bot.echo))
    dp.add_handler(MessageHandler(Filters.command, bot.unknown))
    dp.add_error_handler(bot.error)
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
